require 'active_model'

module ActiveModel
  module Validations
    class ValidationSetValidator < ActiveModel::EachValidator
      include ::ActiveConformity::Reifiers

      attr_accessor :conformer_attrs, :conformable

      def validate_each(conformable, validation_set, validation_set_value)
        @conformable = conformable
        return false unless validation_set_value.is_a? Hash
        validation_set_value.each do |attribute, value|
          return true if attribute == "method" && (value.is_a?(Array) || value.is_a?(String))
          return false unless  is_a_conformists_attribute?(attribute)
           value.each do |rule, constraint|
              validation_rule_conforms?(attribute, rule, constraint)
           end
        end
        true
      end

      def validation_rule_conforms?(attribute, rule, constraint)
        attribute = attribute.to_sym if attribute.is_a?(String)
        rule = rule.to_sym if rule.is_a?(String)
        constraint.symbolize_keys! if constraint.is_a?(Hash)
        begin
          @conformable.class.conformists_names.first.constantize.dup.validates(attribute, reify_regex({rule => constraint}))
        rescue ArgumentError => e
          add_errors(e.to_s)
          false
        end
        true
      end

      def is_a_conformists_attribute?(str)
        if !conformists_attributes.include?(str)
            return add_errors("#{str} is not an attribute of #{conformable.class.conformists_names.first.to_s}!")
        end
        return true
      end

      def conformists_attributes
        conformable.class.conformists_names.flat_map do |conformist|
          if !conformist.constantize.respond_to?(:column_names)
            raise "#{conformist} is not a an active record model!"
          else
            conformist.constantize.column_names
          end
        end
      end

      def add_errors(msg)
        @conformable.errors.add(:validation_set, msg)
        return false
      end
    end
  end
end
