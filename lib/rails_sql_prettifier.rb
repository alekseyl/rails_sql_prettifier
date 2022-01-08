require "rails_sql_prettifier/version"
require 'active_record'
require "niceql"

module RailsSQLPrettifier
  include Niceql

  module ArExtentions
    def exec_niceql
      connection.execute( to_niceql )
    end

    def to_niceql
      Niceql::Prettifier.prettify_sql(to_sql, false)
    end

    def niceql( colorize = true )
      puts Niceql::Prettifier.prettify_sql( to_sql, colorize )
    end

  end

  module PostgresAdapterNiceQL
    def exec_query(sql, name = "SQL", binds = [], prepare: false)
      # replacing sql with prettified sql, thats all
      super( Niceql::Prettifier.prettify_sql(sql, false), name, binds, prepare: prepare )
    end
  end

  module AbstractAdapterLogPrettifier
    def log( sql, *args, &block )
      # \n need to be placed because AR log will start with action description + time info.
      # rescue sql - just to be sure Prettifier wouldn't break production
      formatted_sql = "\n" + Niceql::Prettifier.prettify_sql(sql) rescue sql
      super( formatted_sql, *args, &block )
    end
  end

  module ErrorExt
    def to_s
      # older rails version do not provide sql as a standalone query, instead they
      # deliver joined message
      Niceql.config.prettify_pg_errors ? Niceql::Prettifier.prettify_err(super, try(:sql) ) : super
    end
  end

  module ARNiceQLConfig
    extend ActiveSupport::Concern

    included do
      attr_accessor :pg_adapter_with_nicesql,
                    :prettify_active_record_log_output,
                    :prettify_pg_errors
    end


    def ar_using_pg_adapter?
      ActiveRecord::Base.connection_db_config.adapter == 'postgresql'
    end

    def initialize
      super
      self.pg_adapter_with_nicesql = false
      self.prettify_active_record_log_output = false
      self.prettify_pg_errors = ar_using_pg_adapter?
    end

    module ClassMethods
      def configure
        super

        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include(PostgresAdapterNiceQL) if config.pg_adapter_with_nicesql

        ::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend( AbstractAdapterLogPrettifier ) if config.prettify_active_record_log_output

        ::ActiveRecord::StatementInvalid.include( Niceql::ErrorExt ) if config.prettify_pg_errors && config.ar_using_pg_adapter?
      end
    end
  end

  [::ActiveRecord::Relation,
   ::Arel::TreeManager,
   ::Arel::Nodes::Node].each { |klass| klass.send(:include, ArExtentions) }

  NiceQLConfig.include( ARNiceQLConfig )
end
