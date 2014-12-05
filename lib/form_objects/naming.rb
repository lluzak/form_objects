require 'active_support/concern'

module FormObjects
  module Naming
    extend ActiveSupport::Concern

    included do
      def self.model_name
        @model_name ||= ActiveModel::Name.new(self, nil, self.name.gsub(/Form\Z/, ''))
      end
    end
  end
end
