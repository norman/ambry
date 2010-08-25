require "forwardable"

module Prequel

  module Model
    def self.extended(base)
      base.instance_eval do
        @attribute_names = []
        include ModelInstanceMethods
        extend  ModelClassMethods
      end
    end
  end

  # Wrapper around hash instances that allows values to be accessed as symbols,
  # strings or method invocations. It behaves similary to OpenStruct, with the
  # fundamental difference being that you instantiate *one* HashProxy instance
  # and reassign its Hash during a loop in order to avoid creating garbage.
  class HashProxy
    attr :hash

    def method_missing(symbol, *args, &block)
      hash[symbol] or begin
        raise NoMethodError unless hash.has_key?(symbol)
      end
    end

    def [](value)
      hash[value.to_sym] or hash[value.to_s]
    end

    def clear
      @hash = nil
    end

    def using(hash)
      @hash = hash
      self
    end

    def with(hash, &block)
      yield using hash ensure clear
    end
  end

  module ModelClassMethods
    extend Forwardable
    attr_accessor :attribute_names, :key_method, :mapper
    def_delegators :mapper, :[], :[]=, :all, :first, :get, :count, :find, :find_by_key, :keys
    alias attr_key key_method=

    def attr_accessor(*names)
      names.each do |name|
        attribute_names << name
        class_eval(<<-EOM, __FILE__, __LINE__ + 1)
          def #{name}
            @#{name} or (@attributes[:#{name}] if @attributes)
          end

          def #{name}=(value)
            @#{name} = value
          end
        EOM
      end
    end

    def create(hash)
      new(hash).save
    end

    def from_hash(hash)
      instance = allocate
      instance.instance_variable_set :@attributes, hash
      instance
    end

    def key_set(keys)
      KeySet.new(keys, mapper)
    end

    def use(adapter_name)
      self.mapper = Mapper.new(self, adapter_name)
    end

    def with_index(name, &block)
      mapper.indexes[name] or begin
        indexable = yield
        mapper.add_index(name, indexable)
      end
    end
  end

  module ModelInstanceMethods
    def initialize(attributes)
      @attributes = {}
      return unless attributes
      attributes.each do |key, value|
        key = key.to_sym
        @attributes[key] = value if self.class.attribute_names.include?(key)
      end
    end

    def to_hash
      self.class.attribute_names.inject({}) do |hash, key|
        hash[key] = self.send(key); hash
      end
    end

    def to_key
      send self.class.key_method
    end

    def save
      self.class.mapper.put(self)
    end

    def with_index(name, &block)
      self.class.with_index(name, &block)
    end
  end
end
