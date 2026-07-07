# frozen_string_literal: true

require_relative "../test_helper"

class ProtectedEnvTest < ActiveSupport::TestCase
  test "protected_env? returns false when database does not exist" do
    ActiveRecord::Base.connection.stub(:database_exists?, false) do
      assert_equal false, Niceql.protected_env?
    end
  end
end
