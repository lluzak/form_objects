module FormObjects
  class ParamsConverter
    class DateConverter
      DATE_ATTRIBUTES = /^(\w+)\(.i\)$/
      DATE_FORMAT     = "%s.%s.%s %s:%s:%s".freeze

      def initialize(params)
        @params = params
      end

      def params
        convert_attributes_to_date(@params)
      end

      def convert_attributes_to_date(object)
        return object unless object.respond_to?(:each_pair)

        object.inject({}) { |hash, attributes|
          key, value      = attributes.first, attributes.last
          attribute       = date_attribute_name_for(key)
          hash[attribute] = DATE_FORMAT % date_values_for(key, object) if candidate_for_date_conversion?(key)
          hash[key]       = convert_attributes_to_date(value)

          hash
        }
      end

      def date_attribute_name_for(key)
        key[DATE_ATTRIBUTES, 1]
      end

      def date_values_for(key, object)
        (1..6).map { |value| "#{object.delete("#{date_attribute_name_for(key)}(#{value}i)") { "00" }}" }
      end

      def candidate_for_date_conversion?(key)
        date_attribute_name_for(key)
      end
    end
  end
end
