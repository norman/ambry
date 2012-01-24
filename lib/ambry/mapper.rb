module Ambry

  # Mappers provide the middle ground between models and adapters. Mappers are
  # responsible for performing finds and moving objects in and out of the
  # hash.
  class Mapper
    extend Forwardable
    attr :hash
    attr_accessor :adapter_name, :klass, :indexes, :options
    def_delegators :hash, :clear, :delete, :key?
    def_delegators :key_set, :all, :count, :find, :find_by_key, :first, :last, :keys

    def initialize(klass, adapter_name = nil, options = {})
      @klass        = klass
      @adapter_name = adapter_name || Ambry.default_adapter_name
      @indexes      = {}
      @lock         = Mutex.new
      @options      = options
      @hash         = adapter.db_for(klass)
    end

    # Returns a hash or model attributes corresponding to the provided key.
    def [](key)
      hash[key] or raise NotFoundError.new(klass, key)
    end

    # Sets a hash by key.
    def []=(key, value)
      @lock.synchronize do
        @indexes = {}
        if value.id_changed?
          hash.delete value.to_id(true)
        end
        saved = hash[key] = value.to_hash.freeze
        adapter.save_database if @options[:sync]
        saved
      end
    end

    # Memoize the output of a find in a threadsafe manner.
    def add_index(name, indexable)
      @lock.synchronize do
        @indexes[name] = indexable
      end
    end

    # Get the adapter.
    def adapter
      Ambry.adapters[adapter_name]
    end

    # Get an instance by key
    def get(key)
      klass.send :from_hash, self[key].merge(klass.id_method => key)
    end

    def key_set
      klass.key_class.new(hash.keys.freeze, self)
    end

    # Sets an instance, invoking its to_id method
    def put(instance)
      self[instance.to_id] = instance
    end
  end
end
