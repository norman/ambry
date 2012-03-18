# Custom validations.
module ActiveModel
  module Validations
    # A uniqueness validator, similar to the one provided by Active Record.
    class UniquenessValidator < ::ActiveModel::EachValidator
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
end
