module FormObjects
  class Base
    include Virtus.model
    include Serializer
    include Nesting

    if ActiveModel::VERSION::MAJOR > 3
      include ActiveModel::Model
    else
      include ActiveModel::Validations
      include ActiveModel::Conversion
      extend ActiveModel::Naming
    end

  end
end
