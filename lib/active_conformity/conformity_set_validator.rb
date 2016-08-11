require 'active_model'

class ConformitySetValidator < ActiveModel::EachValidator
  include ::ActiveConformity::Reifiers

  attr_accessor :conformable

  def validate_each(conformable, conformity_set, conformity_set_value)
    @conformable = conformable
    return add_errors("Conformity set required!") if conformity_set_value.nil?
    begin
      if conformity_set_value.is_a? String
        conformity_set_value = JSON.parse(conformity_set_value)
      end
    rescue
      return add_errors "#{conformity_set_value} cannot be parsed to a hash!"
    end
    conformity_set_value.each do |attribute, value|
      return validate_custom_method(value) if attribute.to_sym == :method
      validate_attr_based_validations(attribute, value)
    end
  end

  private

  def validate_attr_based_validations(attribute, value)
    is_a_conformists_attribute?(attribute)
    value.each do |rule, constraint|
      validation_rule_conforms?(attribute, rule, constraint)
    end
  end

  def custom_method_is_defined?(method_name)
    ActiveConformityCustomMethods.public_instance_methods.include?(method_name.to_sym)
  end

  def custom_method_error(method_name)
    add_errors("#{method_name} is not defined in ActiveConformityCustomMethods!")
  end

  def validate_custom_method(method_name)
    return true
    # custom_method_error(method_name) if !custom_method_is_defined?(method_name) # need a better solution here
  end

  def validation_rule_conforms?(attribute, rule, constraint)
    attribute = attribute.to_sym if attribute.is_a?(String)
    rule = rule.to_sym if rule.is_a?(String)
    constraint.symbolize_keys! if constraint.is_a?(Hash)
    begin
      @conformable.conformist_type.constantize.dup.validates(attribute, reify_regex({rule => constraint}))
    rescue ArgumentError => e
      add_errors(e.to_s)
      false
    end
    true
  end

  def is_a_conformists_attribute?(str)
    # Raise if conformist is not an ActiveRecord model
    if !(conformable.conformist_type.constantize <= ActiveRecord::Base)
      raise "#{conformable.conformist_type} is not a valid conformist, must be an ActiveRecord Model"
    end

    str = str.to_s
    if !conformable.conformist_type.constantize.new.respond_to?("#{str}=")
        return add_errors("#{str} is not a setter for #{conformable.conformist_type.to_s}!")
    end
    return true
  end

  def add_errors(msg)
    @conformable.errors.add(:conformity_set, msg)
    return false
  end
end
