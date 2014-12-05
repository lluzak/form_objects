require 'active_support/core_ext/hash/indifferent_access'
require 'form_objects/params_converter/date_converter'
require 'form_objects/params_converter/collection_converter'

module FormObjects
  class ParamsConverter
    def initialize(params)
      @params = params
    end

    def params
      params = CollectionConverter.new(@params).params
      params = DateConverter.new(params).params

      HashWithIndifferentAccess.new(params)
    end
  end
end
