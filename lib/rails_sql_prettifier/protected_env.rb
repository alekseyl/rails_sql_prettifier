# frozen_string_literal: true

module RailsSQLPrettifier
  module ProtectedEnv
    def protected_env?
      migration_context = ActiveRecord::Base.connection.try(:migration_context) ||
        ActiveRecord::Base.connection.try(:pool)&.migration_context # rails 7.2+

      (ActiveRecord::Base.connection.database_exists? && migration_context&.protected_environment?) ||
        defined?(Rails) && ActiveRecord::Base.protected_environments.include?(Rails.env)
    end
  end
end
