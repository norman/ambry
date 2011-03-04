require "active_model"

module Prequel

  # Include this module if you want {Active Model}[http://github.com/rails/rails/tree/master/activemodel] support.
  module ActiveModelSupport

    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Naming
      # extend  ActiveModel::Translation
      # include ActiveModel::Validations
      # include ActiveModel::Serialization
      # include ActiveModel::Serializers::JSON
      # include ActiveModel::Serializers::Xml
      # extend  ActiveModel::Callbacks
      # define_model_callbacks :save, :destroy
    end


    def to_model
      self
    end

    def to_key
      [to_id]
    end

    def to_param
      to_id
    end

    def model_name
      @_model_name ||= ActiveModel::Name.new(self)
    end

  end
end