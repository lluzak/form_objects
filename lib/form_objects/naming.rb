module FormObjects
  module Naming
    def self.extended(base)
      model_name = base.name.gsub(/Form\Z/, '')

      define_method :model_name do
        ActiveModel::Name.new(self, nil, model_name)
      end
    end
  end
end
