module FormObjects
  class ParamsConverter
    class CollectionConverter
      def initialize(params)
        @params = params
      end

      def params
        convert_attributes_to_array(@params)
      end

      def convert_attributes_to_array(object)
        return object unless object.respond_to?(:each_pair)

        object.inject({}) { |hash, attributes|
          key, value = attributes.first, attributes.last
          value      = value.to_a.sort.map { |attributes| attributes.last } if candidate_for_conversion?(key, value)
          hash[key]  = convert_attributes_to_array(value)

          hash
        }
      end

      private

      def candidate_for_conversion?(key, value)
        attribute_key?(key) and value.is_a?(Hash) and incrementing_sequence?(value.keys)
      rescue ArgumentError
        false
      end

      def generate_sequence_from(keys)
        keys.map { |key| Integer(key) }.sort
      end

      def sequence_to(max)
        (0..max).to_a
      end

      def incrementing_sequence?(keys)
        sequence = generate_sequence_from(keys)
        sequence == sequence_to(sequence.max)
      end

      def attribute_key?(key)
        key =~ /_attributes$/
      end
    end
  end
end

