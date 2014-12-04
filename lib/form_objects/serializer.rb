module FormObjects
  module Serializer

    def serialized_attributes
      (attributes || {}).inject({}) do |hash, (name, value)|
        hash[name] = value.respond_to?(:serialized_attributes) ? value.serialized_attributes : value
        hash
      end
    end

  end
end
