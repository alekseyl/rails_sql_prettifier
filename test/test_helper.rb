$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.expand_path('../../test/rails_sql_prettifier', __FILE__)

require 'minitest/autorun'
require 'byebug'
require 'active_record'
require 'stubberry'
require 'pg'
require 'active_support/testing/declarative'
require 'active_support/testing/assertions'
require 'rails_sql_prettifier'
