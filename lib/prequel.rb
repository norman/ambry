require "forwardable"
require "thread"
require "prequel/adapter"
require "prequel/key_set"
require "prequel/mapper"
require "prequel/model"
require "prequel/hash_proxy"
require "prequel/adapters/file"

# Prequel is a database and ORM replacement for small, mostly static models.
#
# Prequel is free software released under the terms of the MIT License.
# @author Norman Clarke
module Prequel
  extend self

  @lock = Mutex.new

  # The default adapter name.
  attr_reader   :default_adapter_name
  @default_adapter_name = :main

  # A hash of all instantiated Prequel adapters.
  attr_reader :adapters
  @adapters = {}

  # Registers an adapter with Prequel. This facilitates allowing models to
  # specify an adapter by name rather than class or instance.
  # @param [Symbol] adapter The adapter name.
  # @see Prequel::Model::ClassMethods#use
  def register_adapter(adapter)
    name = adapter.name.to_sym
    if adapters[name]
      raise PrequelError, "Adapter #{name.inspect} already registered"
    end
    @lock.synchronize do
      adapters[name] = adapter
    end
  end

  # Base error for Prequel.
  class PrequelError < StandardError ; end

  # Raised when a single instance is expected but could not be found.
  class NotFoundError < PrequelError

    # @param [String] klass The class from which the error originated.
    # @param [String] key The key whose lookup trigged the error.
    def initialize(*args)
      super('Could not find %s with key "%s"' % args)
    end
  end
end
