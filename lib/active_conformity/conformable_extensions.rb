require 'active_support/concern'
module ActiveConformity
  module ConformableExtensions
    extend ActiveSupport::Concern

    included do
      has_one :conformable, class_name: "Conformable"
      # this throws weird error
    end


    def conforms?
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set).conforms?
    end

    def conformity_errors
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set).errors.messages
    end

    def conformable_references
      self.class.reflect_on_all_associations
      .select do |reflection|
        ActiveConformity::Conformable.where(conformist_type: self.class.name )
        .pluck(:conformable_type)
        .include?(reflection.klass.name) rescue nil
      end.map(&:name)
      .flat_map{|relation_name| self.send(relation_name) }
    end

    def aggregate_conformity_set
      # still aren't finding custom validation methods
      acs ={}
      conformable_references.each do |c|
        c = ActiveConformity::Conformable.find_by!(conformable_id: c.id, conformable_type: c.class.name).conformity_set
        c = JSON.parse(c) if c.is_a?(String)
        acs.merge!(c)
      end
      acs
    end
  end
end

ActiveRecord::Base.send(:include,ActiveConformity::ConformableExtensions)
