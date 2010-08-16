require "rubygems"
require "bundler/setup"
require "test/unit"
require "dumb_model"

# Allow declarative test definitions inside modules.
class Module
  def test(name, &block)
    define_method("test_#{name.gsub(/[^a-z0-9]/i, "_")}".to_sym, &block)
  end
end

class Person
  extend DumbModel::Base
  attr_accessor :name, :email
  def to_param
    name
  end
end

class Animal
  extend DumbModel::Base
  attr_accessor :species, :common_name
  def to_param
    species
  end
end