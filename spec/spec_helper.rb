require 'rubygems'
require 'rspec'
# require 'debugger' if RUBY_VERSION < '2.0' && RUBY_VERSION >= '1.9'
require 'pry'

$:.push File.expand_path('../lib', __FILE__)
require 'name_parser'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :should
  end
end
