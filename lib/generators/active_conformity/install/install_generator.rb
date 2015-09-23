require 'rails/generators/active_record'
module ActiveConformity
  module Generators
    class Install < Rails::Generators::Base
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      desc "Creates the conformable model and table which stores the conformity sets as json
      and the custom validation methods module in the lib directory."

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def self.next_migration_number(path)
        @migration_number = Time.now.strftime("%Y%m%d%H%M%S")
      end

      def generate_migration
        migration_template "active_conformity_migration.rb.erb", "db/migrate/#{migration_file_name}"
      end

      def migration_name
        "create_conformables"
      end

      def migration_class_name
        migration_name.camelize
      end

      def migration_file_name
        "#{migration_name}.rb"
      end

      def conformity_set_type
        database_adapters.fetch(ActiveRecord::Base.connection.adapter_name, 'json')
      end

      def database_adapters
        {
          'MySQL' => 'json',
          'PostgreSQL' => 'json' # This can be jsonb for 9.4 and above
        }
      end

      def create_custom_methods_module_file
        template "active_conformity_custom_validation_methods.rb.erb", "lib/active_conformity_custom_validation_methods.rb"
      end
    end
  end
end
