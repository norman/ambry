module DumbModel
  module ModelClassMethods

    attr_accessor :mapper

    def fields
      (instance_methods - Object.instance_methods).select do |m|
        method_defined? "#{m}="
      end
    end

    def count(&block)
      mapper.count(to_s, &block)
    end

    def get(id)
      key = "%s:%s" % [to_s, id]
      found = mapper[key]
      new(found) if found
    end

    def find(*args, &block)
      mapper.db.map do |key, value|
        klass, key = key.split(':')
        if result = yield(key, value)
          Object.const_get(klass).new(value)
        end
      end.compact
    end

    def create(attributes)
      new(attributes).save
    end

  end

  module ModelInstanceMethods
    def initialize(options = {})
      options.each {|k, v| self.send "#{k}=", v}
    end

    def to_param
      raise NotImplementedError, "You need to implement a to_param method"
    end

    def to_hash
      self.class.fields.inject({}) do |hash, field|
        hash[field] = send(field); hash
      end
    end

    def save
      self.class.mapper.put(self)
    end
  end

  module Base
    include ModelClassMethods
    def self.extended(base)
      base.send(:include, ModelInstanceMethods)
    end
  end
end