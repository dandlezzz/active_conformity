require 'active_conformity/conformity_set_validator'
module ActiveConformity
  class Conformable < ActiveRecord::Base
    validates :conformity_set, conformity_set: true

    def add_conformity_set(incoming_set={})
      self.conformity_set = JSON.parse(self.conformity_set) if self.conformity_set.is_a?(String)
      conformity_set = JSON.parse(incoming_set) rescue incoming_set
      conformity_set = self.conformity_set.deep_merge(incoming_set) rescue conformity_set
      self.conformity_set = conformity_set.to_json
    end

    def conformity_set
      if super.is_a? String
        JSON.parse(super).deep_symbolize_keys! rescue super
      else
        super
      end
    end

    def remove_coformity_rule(attr)
      conformity_set = JSON.parse(self.conformity_set) rescue self.conformity_set
      conformity_set.delete(attr) do
        raise "no rule found for #{attr.to_s}"
      end
      self.conformity_set = conformity_set.to_json
    end

    def remove_rules
      self.conformity_set = {}.to_json
    end

    def remove_rules!
      remove_rules
      save!
    end

    def remove_coformity_rule!(attr)
      remove_coformity_rule(attr)
      save!
    end
  end
end
