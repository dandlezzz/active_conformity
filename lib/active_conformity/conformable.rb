require 'active_conformity/validation_set_validator'
module ActiveConformity
  module Conformable
    extend ActiveSupport::Concern
    include ActiveModel::Validations

    included do
      validates :validation_set, validation_set: true
    end

    module ClassMethods
      @conformists_names = []

      def conformists_names
        @conformists_names
      end

      def conformists(*klass_names)
        @conformists_names = klass_names
      end
    end

    def add_validations(validations={})
      self.validation_set = {} if self.validation_set.nil?
      self.validation_set = self.validation_set.deep_merge(validations)
      self.update_column(:validation_set, self.validation_set)
    end
  end
end
