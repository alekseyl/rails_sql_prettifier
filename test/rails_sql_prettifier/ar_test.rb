require_relative '../test_helper'


# ActiveRecord::Base.establish_connection(
#   adapter: 'sqlite3',
#   database: ':memory:'
# )

ActiveRecord::Base.establish_connection(
  adapter: 'postgresql',
  database: 'niceql-test',
  user: 'postgres'
)

Niceql.configure { |config|
  config.pg_adapter_with_nicesql = false
  config.prettify_active_record_log_output = false
}

ActiveRecord::Migration.create_table(:users, force: true)
ActiveRecord::Migration.create_table(:comments, force: true) do |t|
  t.belongs_to :user
end

class User < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
end

class ARTest < ActiveSupport::TestCase
  extend ::ActiveSupport::Testing::Declarative
  include Stubberry::Assertions
  # include ::ActiveSupport::Testing::Assertions

  test 'ar_using_pg_adapter? whenever AR is not defined will be false' do
    assert_equal( ActiveRecord::Base.connection_db_config.adapter, 'sqlite3' )
    assert( !Niceql::NiceQLConfig.new.ar_using_pg_adapter? )
  end

  test 'ar_using_pg_adapter? should be true whenever connection_db_config.adapter is postgresql' do
    ActiveRecord::Base.connection_db_config.stub(:adapter, 'postgresql') {
      assert(Niceql::NiceQLConfig.new.ar_using_pg_adapter?)
    }
  end

  test 'accessible through ActiveRecord and Arel' do
    User.create
    assert(!User.respond_to?(:to_niceql))                # ActiveRecord::Base
    assert(User.all.to_niceql.is_a?(String))             # ActiveRecord::Relation
    assert(User.last.comments.to_niceql.is_a?(String))   # ActiveRecord::Associations::CollectionProxy
    assert(User.all.arel.to_niceql.is_a?(String))        # Arel::TreeManager
    assert(User.all.arel.source.to_niceql.is_a?(String)) # Arel::Nodes::Node
  end

  #
  test 'log got called and then prettifier got called' do

    assert_method_called( ActiveRecord::Base.connection, :log ) do
      Niceql::Prettifier.stub_must_not( :prettify_sql ) { User.where(id: 1).load }
    end

    Niceql.configure { |config| config.prettify_active_record_log_output = true }

    assert_method_called( ActiveRecord::Base.connection, :log ) do
      Niceql::Prettifier.stub_must(:prettify_sql, -> (sql) {
        assert_equal(sql, 'SELECT "users".* FROM "users" WHERE "users"."id" = $1')
        sql
      }) { User.where(id: 1).load }
    end

  end

end