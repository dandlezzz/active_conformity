# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_conformity/version'

Gem::Specification.new do |spec|
  spec.name          = "active_conformity"
  spec.version       = ActiveConformity::VERSION
  spec.authors       = ["dandlezzz"]
  spec.email         = ["danm@workwithopal.com"]

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.summary       = "Shared validations for models and your apis"
  spec.description   = "Store rails validations as JSON to expose to your apis and share amongst ActiveRecord models"
  spec.homepage      = "http://www.github.com/dandlezzz/active_conformity"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
