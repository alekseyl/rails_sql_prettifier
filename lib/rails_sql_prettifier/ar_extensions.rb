# frozen_string_literal: true

module RailsSQLPrettifier

  module ArExtentions
    def exec_niceql(reraise = false)
      connection.execute( to_niceql )
    rescue => e
      puts Niceql::Prettifier.prettify_pg_err( e.message, to_niceql )
      raise if reraise
    end

    def to_niceql
      Niceql::Prettifier.prettify_sql(to_sql, false)
    end

    def niceql( colorize = true )
      puts Niceql::Prettifier.prettify_sql( to_sql, colorize )
    end
  end
end
