# frozen_string_literal: true

module RailsSQLPrettifier
  module NiceQLConfigExt
    extend ActiveSupport::Concern

    included do
      attr_accessor :pg_adapter_with_nicesql,
        :prettify_active_record_log_output,
        :prettify_pg_errors

      # we need to use a prepend otherwise it's not preceding Niceql.configure in a lookup chain
      Niceql.singleton_class.prepend(Configure)
    end

    def ar_using_pg_adapter?
      ActiveRecord::Base.connection_db_config.adapter == "postgresql"
    end

    def initialize
      super
      self.pg_adapter_with_nicesql = false
      self.prettify_active_record_log_output = false
      self.prettify_pg_errors = ar_using_pg_adapter?
    end

    module Configure
      def configure
        super

        if config.pg_adapter_with_nicesql &&
            defined?(::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) && !protected_env?

          ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include(PostgresAdapterNiceQL)
        end

        if config.prettify_active_record_log_output
          ::ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(AbstractAdapterLogPrettifier)
        end

        if config.prettify_pg_errors && config.ar_using_pg_adapter?
          ::ActiveRecord::StatementInvalid.include(NiceqlError)
        end
      end
    end
  end
end
