# frozen_string_literal: true

require "test_helper"
require "differ"
require "byebug"

# we need to add this cause original include in the configure wants pg to be present
# but that is not an issue for a testing
ActiveRecord::StatementInvalid.include(RailsSQLPrettifier::NiceqlError)

# activerecord will not include adapter by default, unless we use a pg connection setup
unless defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
  class ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
  end
end

unless defined?(Rails)
  module Rails
    def self.env; end
  end
end

class NiceQLTest < Minitest::Test
  extend ::ActiveSupport::Testing::Declarative

  def self.test(*args, &block)
    super(*args) do
      Niceql.stub(:config, Niceql::NiceQLConfig.new) do
        instance_eval(&block)
      end
    end
  end

  def assert_equal_standard(niceql_result, etalon)
    return unless etalon != niceql_result

    puts "ETALON:----------------------------"
    puts etalon
    puts "Niceql result:---------------------"
    puts niceql_result
    puts "DIFF:----------------------------"
    puts Differ.diff(etalon, niceql_result)
    raise "Not equal"
  end

  def test_niceql
    etalon = <<~PRETTY_RESULT
      -- valuable comment first line
      SELECT some,
        -- valuable comment to inline verb
        COUNT(attributes), /* some comment */#{" "}
        CASE WHEN some > 10 THEN '[{"attr": 2}]'::jsonb[] ELSE '{}'::jsonb[] END AS combined_attribute, more
        -- valuable comment to newline verb
        FROM some_table st
        RIGHT INNER JOIN some_other so ON so.st_id = st.id
        /* multi line with semicolon;
           comment */
        WHERE some NOT IN (
          SELECT other_some
          FROM other_table
          WHERE id IN ARRAY[1,2]::bigint[]
        )
        ORDER BY some
        GROUP BY some
        HAVING 2 > 1;
      --comment to second query;
      SELECT other
        FROM other_table;
    PRETTY_RESULT

    prettySQL = Niceql::Prettifier.prettify_multiple(<<~PRETTIFY_ME, false)
      -- valuable comment first line
      SELECT some,
      -- valuable comment to inline verb
      COUNT(attributes), /* some comment */ CASE WHEN some > 10 THEN '[{"attr": 2}]'::jsonb[] ELSE '{}'::jsonb[] END AS combined_attribute, more 
      -- valuable comment to newline verb
      FROM some_table st RIGHT INNER JOIN some_other so ON so.st_id = st.id      
      /* multi line with semicolon;
         comment */
      WHERE some NOT IN (SELECT other_some FROM other_table WHERE id IN ARRAY[1,2]::bigint[] ) ORDER BY   some GROUP BY some       HAVING 2 > 1;
      --comment to second query;
      SELECT other FROM other_table;
    PRETTIFY_ME

    # ETALON goes with \n at the end :(
    assert_equal_standard(prettySQL, etalon.chop)
  end

  def broken_sql_sample
      <<~SQL
        SELECT err
        FROM ( VALUES(1), (2) )
        WHERE id="100"
        ORDER BY 1
    SQL
  end

  def err_template
    <<~ERR
      SELECT err
      _COLORIZED_ERR_WHERE id="100"
      ORDER BY 1
    ERR
  end

  def prepare_sample_err( base_err, prt_err_sql )
    standard_err = base_err + prt_err_sql.gsub(/#{Niceql::Prettifier::KEYWORDS}/ ) { |verb| Niceql::StringColorize.colorize_keyword(verb) }
      .gsub(/#{Niceql::Prettifier::STRINGS }/ ) { |verb| Niceql::StringColorize.colorize_str(verb) }

    standard_err.gsub!("_COLORIZED_ERR_", Niceql::StringColorize.colorize_err("FROM ( VALUES(1), (2) )\n") +
      Niceql::StringColorize.colorize_err("     ^\n"))
    standard_err
  end

  test "Statement Invalid new format" do
    err = <<~ERR
      ERROR: VALUES in FROM must have an alias
      LINE 2: FROM ( VALUES(1), (2) )
                   ^
    ERR
    si = ActiveRecord::StatementInvalid.new(err, sql: broken_sql_sample)

    Niceql.config.stub(:prettify_pg_errors, true) do
      assert_equal_standard(si.to_s, prepare_sample_err(err, err_template))
    end
  end

  test "Statement Invalid old format" do
    err = <<~ERR
      ERROR: VALUES in FROM must have an alias
      LINE 2: FROM ( VALUES(1), (2) )
                   ^
    ERR
    si = ActiveRecord::StatementInvalid.new(err + broken_sql_sample)

    Niceql.config.stub(:prettify_pg_errors, true) do
      si.singleton_class.undef_method(:sql) if si.respond_to?(:sql)
      assert_raises { si.sql }
      assert_equal_standard(si.to_s, prepare_sample_err(err, err_template))
    end
  end

  test "PostgreSQLAdapter will include PostgresAdapterNiceQL after config setup" do
    Niceql.stub_must(:protected_env?, false) do
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.stub_must(:include, -> ( _module ) {
        assert_equal(_module, RailsSQLPrettifier::PostgresAdapterNiceQL)
      }) do
        Niceql.configure { |c| c.pg_adapter_with_nicesql = true }
      end
    end
  end

  test "PostgreSQLAdapter will not include PostgresAdapterNiceQL if env is protected" do
    Niceql.stub_must(:protected_env?, true) do
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.stub_must_not(:include) do
        Niceql.configure { |c| c.pg_adapter_with_nicesql = true }
      end
    end
  end

  test "PostgreSQLAdapter will not be updated for Rails production even when pg_adapter_with_nicesql is true" do
    Rails.stub_must(:env, ActiveSupport::EnvironmentInquirer.new("production")) do
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.stub_must_not(:include) do
        Niceql.configure { |c| c.pg_adapter_with_nicesql = true }
      end
    end
  end

  test "PostgreSQLAdapter will be updated for Rails development env" do
    Rails.stub_must(:env, ActiveSupport::EnvironmentInquirer.new("development")) do
      ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.stub_must(:include, :do_nothing) do
        Niceql.configure { |c| c.pg_adapter_with_nicesql = true }
      end
    end
  end

  test "AbstractAdapter will be extended with AbstractAdapterLogPrettifier after config setup" do
    ::ActiveRecord::ConnectionAdapters::AbstractAdapter.stub_must(:prepend, lambda { |_module|
      assert_equal(_module, RailsSQLPrettifier::AbstractAdapterLogPrettifier)
    }) do
      Niceql.configure { |c| c.prettify_active_record_log_output = true }
    end
  end

  test "StatementInvalid will include ErrorExt only when ar_using_pg_adapter? is true and prettify_pg_errors true" do
    ActiveRecord::Base.connection_db_config.stub(:adapter, "sqlite3") do
      assert(!Niceql::NiceQLConfig.new.ar_using_pg_adapter?)

      ::ActiveRecord::StatementInvalid.stub_must_not(:include) do
        Niceql.configure { |c| c.prettify_pg_errors = true }
      end
    end

    ::ActiveRecord::StatementInvalid.stub_must(:include, lambda { |_module|
      assert_equal(_module, RailsSQLPrettifier::NiceqlError)
    }) { Niceql.configure { |c| c.prettify_pg_errors = true } }
  end
end
