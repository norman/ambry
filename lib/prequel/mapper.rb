require "forwardable"

module Prequel

  # Mappers provide the middle ground between models and adapters. Mappers are
  # responsible for performing finds and moving objects in an out of the
  # database.
  class Mapper
    extend Forwardable
    attr_accessor :adapter_name, :klass, :indexes
    def_delegators :hash, :clear, :delete
    def_delegators :key_set, :count, :find, :find_by_key

    def initialize(klass, adapter_name = nil)
      @klass        = klass
      @adapter_name = adapter_name || Prequel.default_adapter_name
      @indexes      = {}
      adapter.db[klass.to_s] ||= {}
    end

    # Returns a hash
    def [](key)
      hash[key] or raise NotFoundError.new(klass, key)
    end

    # Sets a hash by key
    def []=(key, value)
      hash[key] = value.to_hash.freeze
      clear_indexes
    end

    def add_index(name, key_set)
      @lock.synchronize do
        @indexes[name] = key_set
      end
    end

    def clear_indexes
      indexes.clear
    end

    # Get an instance by key
    def get(key)
      klass.from_hash self[key]
    end

    def hash
      adapter.db[klass.to_s]
    end

    def key_set
      adapter.key_set(self)
    end

    # Sets an instance, invoking its to_key method
    def put(instance)
      self[instance.to_key] = instance
      instance
    end
  end
end
