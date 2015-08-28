require 'active_model/validations'
module ActiveConformity
  class DynamicValidator
     include ActiveModel::Validations
     attr_reader :obj
     attr_accessor :method_args

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

    attr_accessor :conformity_set, :errors, :validation_results,
                  :obj, :validator_klass, :conforms, :method_args

    def initialize(obj, conformity_set)
      @obj = obj
      @conformity_set = ::HashWithIndifferentAccess.new(conformity_set)
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

    def validation_results
      # This doesn't seem needed
      [@valid, @errors]
    end

    def errors
      check_conformity
      @errors
    end

    def check_conformity
      @conformity_set.map do |attr,rule|
        call_validation_method(attr, rule)
      end
      validator = @validator_klass.new(@obj)
      if @conformity_set["method"] && @conformity_set["method"].length > 1
        validator.method_args = @conformity_set["method"][1..-1]
      end
      @conforms = validator.valid?
      @errors = validator.errors
    end

    def reify_rule(rule)
      HashWithIndifferentAccess.new reify_regex(rule)
    end

    def call_validation_method(attr, rule)
      if attr == "method"
        add_custom_validations
        rule = [rule].flatten
        @validator_klass.validate rule[0].to_sym
      else
        @validator_klass.validates attr.to_sym, reify_rule(rule)
      end
    end

    def add_custom_validations
      @validator_klass.class_eval do
        include ::ActiveConformity::CustomValidationMethods
      end
    end
  end
end
