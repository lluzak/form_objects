module FormObjects
  module Nesting

    def self.included(base)
      base.extend(ClassMethods)
    end

    protected

    def validate_and_copy_errors(parent_form, attribute_name)
      valid?

      self.errors.each do |key, message|
        parent_form.errors["#{attribute_name}_#{key}"] = message
      end
    end

    private

    def validate_nested_attributes(attributes)
      attributes.each do |attribute_name|
        attribute_value = __send__(attribute_name)
        [*attribute_value].each{|val| val.validate_and_copy_errors(self, attribute_name) }
      end
    end

    module ClassMethods
      def nested_forms(*attributes)
        assert_valid_attributes!(attributes)

        attributes.each do |name|
          define_nested_writer_method(name)
        end

        validate { validate_nested_attributes(attributes) }
      end

      def assert_valid_attributes!(attributes)
        unknown_attributes = attributes - attribute_set.to_enum.map(&:name)

        raise ArgumentError,"Unknown attributes: #{unknown_attributes.join(', ')}" if unknown_attributes.present?
      end

      def define_nested_writer_method(method_name)
        define_method "#{method_name}_attributes=" do |data|
          self.__send__("#{method_name}=", data)
        end
      end
    end

  end
end
