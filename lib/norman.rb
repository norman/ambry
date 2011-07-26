require "forwardable"
require "thread"
require "norman/adapter"
require "norman/abstract_key_set"
require "norman/mapper"
require "norman/model"
require "norman/hash_proxy"
require "norman/adapters/file"

# Norman is a database and ORM replacement for small, mostly static models.
#
# Norman is free software released under the terms of the MIT License.
# @author Norman Clarke
module Norman
  extend self

  @lock = Mutex.new

  # The default adapter name.
  attr_reader   :default_adapter_name
  @default_adapter_name = :main

  # A hash of all instantiated Norman adapters.
  attr_reader :adapters
  @adapters = {}

  # Registers an adapter with Norman. This facilitates allowing models to
  # specify an adapter by name rather than class or instance.
  #
  # @param [Symbol] adapter The adapter name.
  # @see Norman::Model::ClassMethods#use
  def register_adapter(adapter)
    name = adapter.name.to_sym
    if adapters[name]
      raise NormanError, "Adapter #{name.inspect} already registered"
    end
    @lock.synchronize do
      adapters[name] = adapter
    end
  end

  # Base error for Norman.
  class NormanError < StandardError ; end

  # Raised when a single instance is expected but could not be found.
  class NotFoundError < NormanError

    # @param [String] klass The class from which the error originated.
    # @param [String] key The key whose lookup trigged the error.
    def initialize(*args)
      super('Could not find %s with key "%s"' % args)
    end
  end
end
