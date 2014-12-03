module FormObjects
  module Nesting
    def nested_form(attribute, form, options = {})
      attribute(attribute, form, options)
      validates_associated(attribute)
      define_nested_writer_method(attribute)
    end

    def define_nested_writer_method(method_name)
      alias_method :"#{method_name}_attributes=", :"#{method_name}="
    end
  end
end
