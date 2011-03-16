if ENV["coverage"]
  require "simplecov"
  SimpleCov.start
end
require "rubygems"
require "bundler/setup"
require "prequel"
require "prequel/adapters/yaml"
require 'minitest/spec'
require "mocha"
require "fileutils"
require "ffaker"

class Person
  extend Prequel::Model
  field :email, :name
  use :main

  filters do
    def stooges
      find_by_key {|k| k =~ /3stooges.com/}
    end

    def non_howards
      find {|p| p[:name] !~ /Howard/}
    end
  end
end

def load_fixtures
  Prequel.adapters.clear
  file = File.expand_path("../fixtures.yml", __FILE__)
  Prequel::Adapters::YAML.new :name => :main, :file => file
end

MiniTest::Unit.autorun
