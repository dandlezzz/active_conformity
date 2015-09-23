require 'rails/generators/active_record'
module ActiveConformity
  module Generators
    class Install < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      desc "Creates the conformable model and table which stores the conformity sets as json \n
      and the custom validation methods module in the lib directory."

      def generate_model
        generate("model", "Conformable","conformity_set:jsonb conformable_type:string conformable_id:integer conformist_type:string")
      end

      def create_custom_methods_module_file
        template "active_conformity_custom_validation_methods.rb.erb", "lib/active_conformity_custom_validation_methods.rb"
      end
    end
  end
end
