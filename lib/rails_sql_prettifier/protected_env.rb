# frozen_string_literal: true

module RailsSQLPrettifier

  module ProtectedEnv
    def protected_env?
      ActiveRecord::Base.connection.migration_context.protected_environment? ||
        defined?(Rails) && !(Rails.env.test? || Rails.env.development?)
    end
  end
end
