module FormObjects
  module Serializer

    def serialized_attributes
      (attributes || {}).inject({}) do |hash, (name, value)|
        hash[name] = value.is_a?(Array) ? value.map { |item| serialize(item) } : serialize(value)
        hash
      end
    end

    private

    def serialize(value)
      value.respond_to?(:serialized_attributes) ? value.serialized_attributes : value
    end

  end
end
