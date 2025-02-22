# frozen_string_literal: true
module RailsSQLPrettifier
  module NiceqlError
    def to_s
      # older rails version do not provide sql as a standalone query, instead they
      # deliver joined message, and try(:sql) will set prettify_err with nil in that case
      Niceql.config.prettify_pg_errors ? Niceql::Prettifier.prettify_err(super, try(:sql) ) : super
    end
  end
end
