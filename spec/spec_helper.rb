$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'yaml'
require 'active_record'
require 'active_support/all'
require 'support/active_conformity_custom_methods'
require 'active_conformity'
require 'support/model_reconstruction'

RSpec.configure do |config|
  config.include ModelReconstruction
end


config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])
