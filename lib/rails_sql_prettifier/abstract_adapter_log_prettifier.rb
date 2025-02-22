# frozen_string_literal: true

module RailsSQLPrettifier
  module AbstractAdapterLogPrettifier
    private

    def log(sql, *args, **kwargs, &block)
      # \n need to be placed because AR log will start with action description + time info.
      # rescue sql - just to be sure Prettifier wouldn't break production
      formatted_sql = "\n" + Niceql::Prettifier.prettify_sql(sql) rescue sql

      super(formatted_sql, *args, **kwargs, &block)
    end
  end
end
