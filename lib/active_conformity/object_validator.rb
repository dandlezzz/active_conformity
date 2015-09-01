Object.send(:remove_const, :ActiveConformityCustomMethods) if Rails rescue false
require 'active_conformity_custom_methods'
require 'active_model/validations'
module ActiveConformity
  class DynamicValidator
    include ActiveModel::Validations
    include ::ActiveConformityCustomMethods

    attr_reader :obj

    def initialize(obj)
      @obj = obj
      set_accessors
    end

    def set_accessors
      obj.attributes.each do |k,v|
        self.class_eval do
          attr_accessor k.to_sym
        end
        instance_variable_set("@#{k}", v)
      end
    end
  end

  class ObjectValidator
    include ActiveConformity::Reifiers

    attr_accessor :conformity_set, :errors, :obj,
                  :validator_klass, :conforms, :validator


    def initialize(obj, conformity_set)
      @obj = obj
      @conformity_set = ::HashWithIndifferentAccess.new(conformity_set)
      @errors = {}
      create_validator_klass
    end

    def conforms?
      @conforms = true if @conformity_set.blank?
      check_conformity
      @conforms
    end

    def create_validator_klass
      validator_klass_name = (0...50).map { ('A'..'Z').to_a[rand(26)] }.join
      @validator_klass = Object.const_set(validator_klass_name, Class.new(DynamicValidator))
    end

    def errors
      check_conformity
      @errors
    end

    def check_conformity
      @conformity_set.each do |attr,rule|
        call_validation_method(attr, rule)
      end
      @validator = @validator_klass.new(@obj)
      @conforms = @validator.valid?
      @errors = @validator.errors
    end

    def call_validation_method(attr, rule)
      if attr.to_sym == :method
        @validator_klass.validate rule.to_sym
      else
        @validator_klass.validates attr, reify_rule(rule)
      end
    end
  end
end
