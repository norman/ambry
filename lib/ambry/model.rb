module Ambry

  module Model
    def self.extended(base)
      base.instance_eval do
        @lock            = Mutex.new
        @attribute_names = []
        @key_class       = Class.new(Ambry::AbstractKeySet)
        extend  ClassMethods
        include InstanceMethods
        include Comparable
      end
    end

    module ClassMethods
      extend Forwardable
      attr_accessor :attribute_names, :id_method, :mapper
      attr_reader :key_class
      def_delegators(*[:find, Enumerable.public_instance_methods(false)].flatten)
      def_delegators(:mapper, :[], :all, :delete, :first, :last, :get, :count, :find, :find_by_key, :keys, :key?)
      alias id_field id_method=

      def field(*names)
        names.each do |name|
          # First attribute added is the default id
          id_field name if attribute_names.empty?
          attribute_names << name.to_sym
          class_eval(<<-EOM, __FILE__, __LINE__ + 1)
            def #{name}
              defined?(@#{name}) ? @#{name} : @attributes[:#{name}]
            end

            def #{name}=(value)
              @#{name} = value
            end
          EOM
        end
      end

      def use(adapter_name, options = {})
        @mapper         = nil
        @adapter_name   = adapter_name
        @mapper_options = options
      end

      # Memoize the output of the method call invoked in the block.
      # @param [#to_s] name If not given, the name of the method calling with_index will be used.
      def with_index(name = nil, &block)
        name ||= caller(1)[0].match(/in `(.*)'\z/)[1]
        mapper.indexes[name.to_s] or begin
          indexable = yield
          mapper.add_index(name, indexable)
        end
      end

      def create(hash)
        new(hash).save
      end

      # The point of this method is to provide a fast way to get model instances
      # based on the hash attributes managed by the mapper and adapter.
      #
      # The hash arg gets frozen, which can be a nasty side-effect, but helps
      # avoid hard-to-track-down bugs if the hash is updated somewhere outside
      # the model. This should only be used internally to Ambry, which is why
      # it's private.
      def from_hash(hash)
        instance = allocate
        instance.instance_variable_set :@attributes, hash.freeze
        instance
      end
      private :from_hash

      def filters(&block)
        key_class.class_eval(&block)
        key_class.instance_methods(false).each do |name|
        instance_eval(<<-EOM, __FILE__, __LINE__ + 1)
          def #{name}(*args)
            mapper.key_set.#{name}(*args)
          end
        EOM
        end
      end

      def mapper
        @mapper or @lock.synchronize do
          name      = @adapter_name || Ambry.default_adapter_name
          options   = @mapper_options || {}
          @mapper ||= Mapper.new(self, name, options)
        end
      end

      def inspect
        "#{name}(#{attribute_names * ', '})"
      end
    end

    module InstanceMethods

      # Ambry models can be instantiated with a hash of attribures, a block,
      # or both. If both a hash and block are given, then the values set inside
      # the block will take precedence over those set in the hash.
      #
      # @example
      #   Person.new :name => "Joe"
      #   Person.new {|p| p.name = "Joe"}
      #   Person.new(params[:person]) {|p| p.age = 38}
      #
      def initialize(attributes = nil, &block)
        @attributes = {}.freeze
        return unless attributes || block_given?
        if attributes
          self.class.attribute_names.each do |name|
            value = attributes[name] || attributes[name.to_s]
            send("#{name}=", value) if value
          end
        end
        yield self if block_given?
      end

      # Ambry models implement the <=> method and mix in Comparable to provide
      # sorting methods. This default implementation compares the result of
      # #to_id. If the items being compared are not of the same kind.
      def <=>(instance)
        to_id <=> instance.to_id if instance.kind_of? self.class
      end

      # Get a hash of the instance's model attributes.
      def to_hash
        self.class.attribute_names.inject({}) do |hash, key|
          hash[key] = self.send(key); hash
        end
      end

      # Returns true is the model's id field has been updated.
      def id_changed?
        to_id != @attributes[self.class.id_method]
      end

      # Invoke the model's id method to return this instance's unique key. If
      # true is passed, then the id will be read from the attributes hash rather
      # than from an instance variable. This allows you to retrieve the old id,
      # in the event that the id has been changed.
      def to_id(use_old = false)
        use_old ? @attributes[self.class.id_method] : send(self.class.id_method)
      end

      # Tell the mapper to save the data for this model instance.
      def save
        self.class.mapper.put(self)
      end

      # Update this instance's attributes and invoke #save.
      def update(attributes)
        HashProxy.with(attributes) do |proxy|
          self.class.attribute_names.each do |name|
            send("#{name}=", proxy[name]) if proxy.key?(name)
          end
        end
        save
      end

      # Tell the mapper to delete the data for this instance.
      def delete
        self.class.delete(self.to_id)
      end

      def inspect
        "#<#{self.class.name} #{self.class.attribute_names.map { |attr| "#{attr}: #{self.send(attr).inspect}" } * ', ' }>"
      end
    end
  end
end
