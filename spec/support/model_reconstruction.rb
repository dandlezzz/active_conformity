class Dummy < ActiveRecord::Base
  belongs_to :dummy_type
  has_many :dummy_options
end

class DummyType < ActiveRecord::Base ; end

class DummyOption < ActiveRecord::Base
  belongs_to :dummy
  belongs_to :option
end

class Option < ActiveRecord::Base ;end

ActiveRecord::Base.send(:include, ActiveConformity::ConformableExtensions)
ActiveRecord::Base.descendants.each do |d|
    next if d ==  ActiveConformity::Conformable
    d.send(:define_method, :conformity_set) {conformable.conformity_set}
end

module ModelReconstruction
  def reset_class class_name
    Object.send(:remove_const, class_name) rescue nil
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))

    klass.reset_column_information
    klass.connection_pool.clear_table_cache!(klass.table_name) if klass.connection_pool.respond_to?(:clear_table_cache!)
    klass.connection.schema_cache.clear_table_cache!(klass.table_name) if klass.connection.respond_to?(:schema_cache)
    klass
  end

  def reset_table table_name, &block
    block ||= lambda { |table| true }
    ActiveRecord::Base.connection.create_table :dummies, {force: true}, &block
  end

  def modify_table table_name, &block
    ActiveRecord::Base.connection.change_table :dummies, &block
  end

  def rebuild_model options = {}
    ActiveRecord::Base.connection.create_table :dummies, force: true do |table|
      table.column :title, :string
      table.column :content, :string
      table.column :views, :integer
      table.column :dummy_type_id, :integer
    end

    ActiveRecord::Base.connection.create_table :options, force: true do |table|
      table.column :dummy_id, :integer
      table.column :option_id, :integer
    end

    ActiveRecord::Base.connection.create_table :dummy_options, force: true do |table|
      table.column :dummy_id, :integer
      table.column :option_id, :integer
      table.column :value, :string
    end

    ActiveRecord::Base.connection.create_table :dummy_types, force: true do |table|
      table.column :system_name, :string
      table.column :name, :string
    end

    ActiveRecord::Base.connection.create_table :conformables, force: true do |table|
      table.column :conformable_type, :string
      table.column :conformable_id, :integer
      table.column :conformist_type, :string
      table.column :conformity_set, :json
    end
  end
end
