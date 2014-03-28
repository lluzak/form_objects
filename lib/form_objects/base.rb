module FormObjects
  class Base
    include Virtus.model
    include Serializer
    extend Nesting

    if ActiveModel::VERSION::MAJOR > 3
      include ActiveModel::Model
    else
      include ActiveModel::Validations
      include ActiveModel::Conversion
      extend ActiveModel::Naming
    end

    def as_json
      to_hash.as_json
    end

    def persisted?
      false
    end

    def self.validates_associated(*attr_names)
      validates_with AssociatedValidator, _merge_attributes(attr_names)
    end
  end
end
