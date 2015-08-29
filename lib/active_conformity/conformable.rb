require 'active_conformity/conformity_set_validator'
module ActiveConformity
  class Conformable < ActiveRecord::Base
    validates :conformity_set, conformity_set: true

    def add_conformity_set(incoming_set={})
      self.conformity_set = JSON.parse(self.conformity_set) if self.conformity_set.is_a?(String)
      conformity_set = self.conformity_set.deep_merge(incoming_set)
      self.update_column(:conformity_set, conformity_set.to_json)
    end

    def remove_validations(attr)
      
    end
  end
end
