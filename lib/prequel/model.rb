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

  module ModelClassMethods
    extend Forwardable
    attr_accessor :attribute_names, :key_method, :mapper
    def_delegators :mapper, :get, :count, :find, :find_by_key
    alias attr_key key_method=

    def attr_accessor(*names)
      names.each do |name|
        attribute_names << name
        class_eval(<<-EOM)
          def #{name}
            @#{name} or @attributes[:#{name}]
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

    def model_proxy
      Thread.current[:model_proxy] ||= ModelProxy.new(self.class)
    end

    def use(adapter_name)
      self.mapper = Mapper.new(self, adapter_name)
    end

    def with_index(name, &block)
      mapper.indexes[name] or begin
        key_set = yield
        unless key_set.is_a?(KeySet)
          raise PrequelError, "Return value must be a key set"
        end
        mapper.add_index(name, key_set)
      end
    end
  end

  module ModelInstanceMethods
    def initialize(attributes)
      @attributes = {}
      return unless attributes
      attributes.each do |key, value|
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
