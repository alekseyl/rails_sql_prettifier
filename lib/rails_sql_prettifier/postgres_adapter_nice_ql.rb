# frozen_string_literal: true

module RailsSQLPrettifier
  module PostgresAdapterNiceQL
    def exec_query(sql, *args, **kwargs, &block)
      # replacing sql with prettified sql, that's all
      super(Niceql::Prettifier.prettify_sql(sql, false), *args, **kwargs, &block)
    end
  end
end
