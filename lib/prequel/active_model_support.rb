require "active_model"

module Prequel

  # Include this module if you want {Active Model}[http://github.com/rails/rails/tree/master/activemodel] support.
  module ActiveModelSupport

    extend ActiveSupport::Concern

    included do
      extend  ActiveModel::Translation
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include ActiveModel::Serialization
      include ActiveModel::Serializers::JSON
      include ActiveModel::Serializers::Xml
      extend  ActiveModel::Callbacks
      define_model_callbacks :save, :destroy
    end

    def save(*args)
      _run_save_callbacks { super }
    end

    def destroy(*args)
      _run_destroy_callbacks { @destroyed = delete(*args) }
    end

    def attributes
      @attributes or begin
        @attributes = to_hash
        @attributes.delete(:_class)
        @attributes.keys.each do |key|
          @attributes[key.to_s] = @attributes.delete(key)
        end
        @attributes
      end
    end

    def persisted?
      !! self.class.get(prequel_id)
    end

    def new_record?
      !! persisted?
    end

    def destroyed?
      @destroyed
    end
  end
end