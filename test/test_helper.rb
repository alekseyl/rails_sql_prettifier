# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../test/rails_sql_prettifier", __dir__))

require "minitest/autorun"
require "minitest/assertions"
require "byebug"
require "active_record"
require "stubberry"
require "pg"
require "active_support/testing/declarative"
require "active_support/testing/assertions"
require "rails_sql_prettifier"
require "awesome_print"
