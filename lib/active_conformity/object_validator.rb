require 'active_model/validations'
module ActiveConformity
  class DynamicValidator
     include ActiveModel::Validations
     include CustomValidationMethods
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

    attr_accessor :validation_set, :errors, :validation_results, :obj, :validator_klass, :valid

    def initialize(obj, validation_set)
      @obj = obj
      @validation_set = HashWithIndifferentAccess.new(validation_set)
      @errors = {}
      create_validator_klass
      validate
    end

    def create_validator_klass
      validator_klass_name = (0...50).map { ('A'..'Z').to_a[rand(26)] }.join
      @validator_klass = Object.const_set(validator_klass_name, Class.new(DynamicValidator))
    end

    def validation_results
      [@valid, @errors]
    end

    def valid?
      @valid
    end

    def validate
      @valid = true if @validation_set.blank?
      run_validations
    end

    def run_validations
      @validation_set.map do |attr,rule|
        call_validation_method(attr, rule)
      end
      validator = @validator_klass.new(@obj)
      @valid = validator.valid?
      @errors = validator.errors
    end

    def reify_rule(rule)
      reify_regex(rule).deep_symbolize_keys
    end

    def call_validation_method(attr, rule)
      if attr == "method"
        add_custom_validations
        @validator_klass.validate rule.to_sym
      else
        @validator_klass.validates attr.to_sym, reify_rule(rule)
      end
    end

    def add_custom_validations
      @validator_klass.class_eval do
        include CustomValidationMethods
      end
    end
  end
end
