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
    attr_accessor :attribute_names, :id_method, :mapper
    def_delegators :mapper, :[], :[]=, :all, :delete, :first, :get, :count, :find, :find_by_key, :keys
    alias attr_id id_method=

    def attr_accessor(*names)
      names.each do |name|
        # First attribute added is the default id
        attr_id name if attribute_names.empty?
        attribute_names << name.to_sym
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

    def mapper
      @mapper or use Prequel.default_adapter_name
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
      self.class.attribute_names.each do |name|
        value = attributes[name] || attributes[name.to_s]
        send("#{name}=", value) if value
      end
    end

    def ==(instance)
      self.class == instance.class && to_id == instance.to_id
    end

    def to_hash
      self.class.attribute_names.inject({}) do |hash, key|
        hash[key] = self.send(key); hash
      end
    end

    def to_id
      send self.class.id_method
    end

    def save
      self.class.mapper.put(self)
    end

  end
end
