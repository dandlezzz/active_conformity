require 'rspec/core/rake_task'



task test: ['spec:unit']

RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc "Run the unit specs"
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = "spec/unit/**/*_spec.rb"
  end
end
