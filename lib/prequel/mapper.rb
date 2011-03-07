module Prequel

  # Mappers provide the middle ground between models and adapters. Mappers are
  # responsible for performing finds and moving objects in and out of the
  # "database."
  class Mapper
    extend Forwardable
    attr_accessor :adapter_name, :klass, :indexes
    def_delegators :hash, :clear, :delete
    def_delegators :key_set, :all, :count, :find, :find_by_key, :keys

    def initialize(klass, adapter_name = nil)
      @klass        = klass
      @adapter_name = adapter_name || Prequel.default_adapter_name
      @indexes      = {}
      @lock         = Mutex.new
      adapter.db[klass.to_s] ||= {}
    end

    # Returns a hash
    def [](key)
      hash[key] or raise NotFoundError.new(klass, key)
    end

    # Sets a hash by key
    def []=(key, value)
      @lock.synchronize do
        hash[key] = value.to_hash.freeze
        @indexes = {}
      end
    end

    def add_index(name, indexable)
      @lock.synchronize do
        @indexes[name] = indexable
      end
    end

    def adapter
      Prequel.adapters[adapter_name]
    end

    def first(&block)
      key_set.first(&block)
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

    # Sets an instance, invoking its to_id method
    def put(instance)
      self[instance.to_id] = instance
      instance
    end
  end
end
