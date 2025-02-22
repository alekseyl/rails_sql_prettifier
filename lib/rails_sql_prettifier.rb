require "rails_sql_prettifier/version"
require "rails_sql_prettifier/abstract_adapter_log_prettifier"
require "rails_sql_prettifier/ar_extensions"
require "rails_sql_prettifier/niceql_error"
require "rails_sql_prettifier/nice_ql_config_ext"
require "rails_sql_prettifier/postgres_adapter_nice_ql"
require "rails_sql_prettifier/protected_env"

require 'active_record'
require "niceql"

module RailsSQLPrettifier
  ::ActiveRecord::Relation.include ArExtentions
  ::Arel::TreeManager.include      ArExtentions
  ::Arel::Nodes::Node.include      ArExtentions

  Niceql::NiceQLConfig.include(NiceQLConfigExt)
  Niceql.extend(ProtectedEnv)
end
