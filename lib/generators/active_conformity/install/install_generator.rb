require 'rails/generators/active_record'
module ActiveConformity
  module Generators
    class Install < Rails::Generators::Base
      desc "Creates the conformable model and table which stores the conformity sets as json"

      def generate_model
        generate("model", "Conformable","conformity_set:jsonb conformable_type:string conformable_id:integer conformist_type:string")
      end
    end
  end
end
