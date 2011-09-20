require "forwardable"
require "thread"
require "ambry/adapter"
require "ambry/abstract_key_set"
require "ambry/mapper"
require "ambry/model"
require "ambry/hash_proxy"
require "ambry/adapters/file"

# Ambry is a database and ORM replacement for small, mostly static models.
#
# Ambry is free software released under the terms of the MIT License.
# @author Norman Clarke
module Ambry
  extend self

  @lock = Mutex.new

  # The default adapter name.
  attr_reader   :default_adapter_name
  @default_adapter_name = :main

  # A hash of all instantiated Ambry adapters.
  attr_reader :adapters
  @adapters = {}

  # Registers an adapter with Ambry. This facilitates allowing models to
  # specify an adapter by name rather than class or instance.
  #
  # @param [Symbol] adapter The adapter name.
  # @see Ambry::Model::ClassMethods#use
  def register_adapter(adapter)
    name = adapter.name.to_sym
    if adapters[name]
      raise AmbryError, "Adapter #{name.inspect} already registered"
    end
    @lock.synchronize do
      adapters[name] = adapter
    end
  end

  # Removes an adapter from Ambry.
  #
  # @param [Symbol] adapter The adapter name.
  def remove_adapter(name)
    @lock.synchronize do
      adapters[name] = nil
      adapters.delete name
    end
  end

  # Base error for Ambry.
  class AmbryError < StandardError ; end

  # Raised when a single instance is expected but could not be found.
  class NotFoundError < AmbryError

    # @param [String] klass The class from which the error originated.
    # @param [String] key The key whose lookup trigged the error.
    def initialize(*args)
      super('Could not find %s with key "%s"' % args)
    end
  end
end

Ambry::Adapter.new
