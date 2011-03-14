module Prequel

  # Mappers provide the middle ground between models and adapters. Mappers are
  # responsible for performing finds and moving objects in and out of the
  # hash.
  class Mapper
    extend Forwardable
    attr :hash
    attr_accessor :adapter_name, :klass, :indexes, :options
    def_delegators :hash, :clear, :delete
    def_delegators :key_set, :all, :count, :find, :find_by_key, :first, :keys

    def initialize(klass, adapter_name = nil, options = {})
      @klass        = klass
      @adapter_name = adapter_name || Prequel.default_adapter_name
      @indexes      = {}
      @lock         = Mutex.new
      @options      = options
      @hash         = adapter.db[klass.to_s] ||= {}
    end

    # Returns a hash
    def [](key)
      hash[key] or raise NotFoundError.new(klass, key)
    end

    # Sets a hash by key
    def []=(key, value)
      @lock.synchronize do
        @indexes = {}
        hash[key] = value.to_hash.freeze
        adapter.save_database if @options[:sync]
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

    # Get an instance by key
    def get(key)
      klass.send :from_hash, self[key]
    end

    def key_set
      adapter.key_set(self)
    end

    # Sets an instance, invoking its to_id method
    def put(instance)
      self[instance.to_id] = instance
    end
  end
end
