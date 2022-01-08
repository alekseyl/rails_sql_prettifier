require_relative '../test_helper'
require 'byebug'

ActiveRecord::Base.logger = Logger.new(STDERR)

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

# ActiveRecord::Base.establish_connection(
#   adapter: 'postgresql',
#   database: 'niceql-test',
#   user: 'postgres'
# )


Niceql.configure { |config|
  config.pg_adapter_with_nicesql = true
  config.prettify_active_record_log_output = true
}

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Migration.create_table(:users, force: true)
ActiveRecord::Migration.create_table(:comments, force: true) do |t|
  t.belongs_to :user
end

class User < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
end

class ARTest < Minitest::Test
  extend ::ActiveSupport::Testing::Declarative

  test 'ar_using_pg_adapter? is false when connection is not using pg' do
    assert( ActiveRecord::Base.connection_config[:adapter] == 'sqlite3')
    assert( !Niceql::NiceQLConfig.new.ar_using_pg_adapter? )
  end

  test 'ar_using_pg_adapter? should be true when the AR connection uses postgres ' do
    ActiveRecord::Base.stub(:connection_config, {adapter: 'postgresql', encoding: 'utf8', database: 'niceql_test'}) {
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
end
