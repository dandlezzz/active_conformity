require 'active_support/concern'
module ActiveConformity
  module ConformableExtensions
    extend ActiveSupport::Concern

    module ClassMethods
      @dependents = []

      def dependents
        @dependents
      end

      def conforming_dependents(*dependents)
        dependents.each do |d|
          if !self.reflect_on_all_associations.map(&:name).include?(d)
            raise "NOT A VALID DEPENDENT, MUST BE ONE OF THE MODEL'S ASSOCIATIONS!"
          end
        end
        @dependents = dependents
      end
    end

    def conforms?
      validator.conforms? && conforming_dependents_conform?
    end

    def conformity_errors
      validator.errors.messages
    end

    def aggregate_conformity_set
      acs = {}
      return acs if !conformable_references.any? #need to think about this a little more
      conformable_references.each do |c|
        # This could be more efficient with some advanced sql techniques
        # Also need indexes on these
        c = Conformable.find_by!(conformable_id: c.id, conformable_type: c.class.name).conformity_set
        c = JSON.parse(c) if c.is_a?(String)
        acs.merge!(c)
      end
      acs
    end

    def method_missing(m, *args, &block)
      if m.to_sym == :conformity_set && !self.class.column_names.include?(m.to_s)
        conformable.try(:conformity_set)
      else
        super
      end
    end

    def conforming_dependents_conform?
      return true if self.class.dependents.blank?
      !self.class.dependents.map do |dependent_association|
        self.send(dependent_association)
      end.flatten.map(&:conforms?).uniq.include?(false)
    end

    def conformity_sets_by_reference
      conformable_references.flat_map do |cr|
        {"#{cr.class.name} id: #{cr.id}"=> cr.conformable.conformity_set}
      end
    end

    def conformable
      @conformable ||= Conformable.find_by(conformable_id: self.id, conformable_type: self.class.name)
      @conformable
    end

    def add_conformity_set!(conformity_set = {}, conformist_type)
      conformable_attrs = {conformable_id: self.id, conformable_type: self.class.name, conformist_type: conformist_type}
      @conformable = Conformable.where(conformable_attrs).first_or_create
      @conformable.add_conformity_set(conformity_set)
      @conformable.save!
    end

    def validator
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set)
    end

    def conformable_references
      [conformable_references_from_associations + add_self_to_conformable_references.to_a]
      .flatten.compact.uniq
    end

    def conformable_references_from_associations
      self.class.reflect_on_all_associations.map do |assoc|
        self.send(assoc.name) if conformable_types.include?(assoc.klass.name) rescue nil
      end.flatten.compact.uniq
    end

    def add_self_to_conformable_references
      [self] if Conformable.where(conformable_id: self.id,
      conformable_type: self.class.name).any?
    end

    def conformable_types
      return @conformable_types if defined?(@conformable_types)
      @conformable_types = conformables_for_class.pluck(:conformable_type)
      @conformable_types
    end

    def conformables_for_class
      return @conformables_for_class if defined?(@conformables_for_class)
      @conformables_for_class = Conformable.where(conformist_type: self.class.name)
      @conformables_for_class
    end
  end
end

ActiveRecord::Base.include ActiveConformity::ConformableExtensions
