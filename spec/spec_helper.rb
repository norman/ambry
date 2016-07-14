if ENV["coverage"]
  require "simplecov"
  SimpleCov.start
end
require "rubygems"
require "bundler/setup"
require "ambry"
require "ambry/adapters/yaml"
require 'minitest/spec'
require "fileutils"
require "ffaker"

class Person
  extend Ambry::Model
  field :email, :name

  def self.stooges
    with_index do
      find_by_key {|k| k =~ /3stooges.com/}
    end
  end

  filters do
    def non_howards
      find {|p| p.name !~ /Howard/}
    end

    def alphabetical
      sort_by {|p| p.name}
    end
  end
end

def load_fixtures
  Ambry.adapters.clear
  file = File.expand_path("../fixtures.yml", __FILE__)
  Ambry::Adapters::YAML.new :file => file
  Person.use :main
end

MiniTest.autorun
