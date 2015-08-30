require 'active_support/concern'
module ActiveConformity
  module ConformableExtensions
    extend ActiveSupport::Concern

    def conforms?
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set).conforms?
    end

    def conformity_errors
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set).errors.messages
    end

    def associations
      @associations ||= self.class.reflect_on_all_associations
      @associations
    end

    def conformable_references
      Conformable.where(conformist_type: self.class.name )
      .pluck(:conformable_type).uniq.flat_map do |c_type|
        associations.detect do |a|
          a.klass.name == c_type
        end
      end.flat_map{|relation| self.send(relation.name) }
    end

    def aggregate_conformity_set
      # still aren't finding custom validation methods
      acs ={}
      return acs if !conformable_references.any? #need to think about this a little more
      conformable_references.each do |c|
        c = ActiveConformity::Conformable.find_by!(conformable_id: c.id, conformable_type: c.class.name).conformity_set
        c = JSON.parse(c) if c.is_a?(String)
        acs.merge!(c)
      end
      acs
    end
  end
end

ActiveRecord::Base.send(:include, ActiveConformity::ConformableExtensions)
