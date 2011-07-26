if ENV["coverage"]
  require "simplecov"
  SimpleCov.start
end
require "rubygems"
require "bundler/setup"
require "norman"
require "norman/adapters/yaml"
require 'minitest/spec'
require "mocha"
require "fileutils"
require "ffaker"

class Person
  extend Norman::Model
  field :email, :name

  def self.stooges
    with_index do
      find_by_key {|k| k =~ /3stooges.com/}
    end
  end

  filters do
    def non_howards
      find {|p| p[:name] !~ /Howard/}
    end
  end
end

def load_fixtures
  Norman.adapters.clear
  file = File.expand_path("../fixtures.yml", __FILE__)
  Norman::Adapters::YAML.new :file => file
  Person.use :main
end

MiniTest::Unit.autorun
