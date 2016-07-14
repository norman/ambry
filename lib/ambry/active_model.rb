require "active_model"

module Ambry
  # Extend this module if you want {Active Model}[http://github.com/rails/rails/tree/master/activemodel]
  # support. Active Model is an API provided by Rails to make any Ruby object
  # behave like an Active Record model instance. You can read an older writeup
  # about it {here}[http://yehudakatz.com/2010/01/10/activemodel-make-any-ruby-object-feel-like-activerecord/].
  module ActiveModel
    def self.extended(base)
      base.instance_eval do
        extend  ClassMethods
        include InstanceMethods
        extend  ::ActiveModel::Naming
        extend  ::ActiveModel::Translation
        include ::ActiveModel::Validations
        include ::ActiveModel::Serializers::JSON
        extend  ::ActiveModel::Callbacks
        define_model_callbacks :save, :destroy
      end
    end

    # Custom validations.
    module Validations
      # A uniqueness validator, similar to the one provided by Active Record.
      class Uniqueness< ::ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          return if record.persisted?
          if attribute.to_sym == record.class.id_method
            begin
              if record.class.mapper[value]
                record.errors[attribute] << "must be unique"
              end
            rescue Ambry::NotFoundError
            end
          else
            if record.class.all.detect {|x| x.send(attribute) == value}
              record.errors[attribute] << "must be unique"
            end
          end
        end
      end
    end

    module ClassMethods
      # Create and save a model instance, raising an exception if any errors
      # occur.
      def create!(*args)
        new(*args).save!
      end

      # Create and save a model instance, returning false if any errors
      # occur.
      def create(*args)
        new(*args).save!
      rescue AmbryError
        false
      end

      # Validate the uniqueness of a field's value in a model instance.
      def validates_uniqueness_of(*attr_names)
        validates_with Validations::Uniqueness, _merge_attributes(attr_names)
      end

      def model_name
        @model_name ||= ::ActiveModel::Name.new(self)
      end
    end

    module InstanceMethods
      def initialize(*args)
        @new_record = true
        super
      end

      def attributes
        hash = to_hash
        hash.keys.each {|k| hash[k.to_s] = hash.delete(k)}
        hash
      end

      def keys
        self.class.attribute_names
      end

      def to_model
        self
      end

      def new_record?
        @new_record
      end

      def persisted?
        !new_record?
      end

      def save
        return false unless valid?
        run_callbacks(:save) do
          @new_record = false
          super
        end
      end

      def save!
        if !valid?
          raise Ambry::AmbryError, errors.to_a.join(", ")
        else
          save
        end
      end

      def to_param
        to_id if persisted?
      end

      def to_key
        [to_param] if persisted?
      end

      def destroy
        run_callbacks(:destroy) { delete }
      end

      def update_attributes(*args)
        run_callbacks(:save) { update(*args) }
      end

      def to_partial_path
        "#{self.class.name.pluralize.underscore}/#{self.class.name.underscore}"
      end
    end
  end
end
