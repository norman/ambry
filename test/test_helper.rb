require "rubygems"
require "bundler/setup"
require 'simplecov'
SimpleCov.start
require "test/unit"
require "prequel"
require "mocha"

# Allow declarative test definitions inside modules.
class Module
  def test(name, &block)
    define_method("test_#{name.gsub(/[^a-z0-9]/i, "_")}".to_sym, &block)
  end
end
