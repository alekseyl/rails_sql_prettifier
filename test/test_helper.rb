$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../test/rails_sql_prettifier', __FILE__)

require 'minitest/autorun'
require 'active_record'
require 'active_support/testing/declarative'
require 'rails_sql_prettifier'
