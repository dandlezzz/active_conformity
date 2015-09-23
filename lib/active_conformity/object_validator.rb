require 'active_model/validations'
begin
  require 'active_conformity_custom_methods'
rescue LoadError
  #lets the user load their own custom methods
end
module ActiveConformity
  class DynamicValidator
    include ActiveModel::Validations
    include ::ActiveConformityCustomMethods rescue false# complicated here

    attr_reader :obj
    attr_accessor :method_args

    def initialize(obj)
      @obj = obj
      @method_args = {}
      set_accessors
    end

    private

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
      remove_dynamic_validator
      @conforms
    end

    def errors
      check_conformity
      remove_dynamic_validator
      @errors
    end

    private

    def remove_dynamic_validator
      Object.send(:remove_const, @validator_klass.name.to_sym)
    end

    def create_validator_klass
      validator_klass_name = (0...50).map { ('A'..'Z').to_a[rand(26)] }.join
      @validator_klass = Object.const_set(validator_klass_name, Class.new(DynamicValidator))
    end

    def check_conformity
      @validator = @validator_klass.new(@obj)
      @conformity_set.each do |attr,rule|
        call_validation_method(attr, rule)
      end
      @conforms = @validator.valid?
      @errors = @validator.errors
    end

    def call_validation_method(attr, rule)
      if attr.to_sym == :method
        if rule.is_a?(String)
          rule_name = rule.to_sym
        elsif rule.is_a?(Hash)
          rule_name = rule[:name].to_sym
          set_custom_method_arguments(rule[:arguments])
        end

        @validator_klass.validate rule_name
      else
        @validator_klass.validates attr, reify_rule(rule)
      end
    end

    def set_custom_method_arguments(args_hash)
      args_hash.each{ |k,v| @validator.method_args[k] = v }
    end
  end
end
