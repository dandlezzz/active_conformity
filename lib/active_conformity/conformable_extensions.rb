require 'active_support/concern'
module ActiveConformity
  module ConformableExtensions
    extend ActiveSupport::Concern

    def conforms?
      new_validator.conforms?
    end

    def conformity_errors
      new_validator.errors.messages
    end

    def aggregate_conformity_set
      acs = {}
      return acs if !conformable_references.any? #need to think about this a little more
      conformable_references.each do |c|
        # This could be more efficient with some advanced sql techniques
        # Also need indexes on these
        c = @conformables_for_class.find_by!(conformable_id: c.id, conformable_type: c.class.name).conformity_set
        c = JSON.parse(c) if c.is_a?(String)
        acs.merge!(c)
      end
      acs
    end

    def new_validator
      ActiveConformity::ObjectValidator.new(self, aggregate_conformity_set)
    end

    def conformable_references
      self.class.reflect_on_all_associations.map do |assoc|
        self.send(assoc.name) if conformable_types.include?(assoc.klass.name) rescue nil
      end.flatten.compact.uniq
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

ActiveRecord::Base.send(:include, ActiveConformity::ConformableExtensions)
