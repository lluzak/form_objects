# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'form_objects/version'

Gem::Specification.new do |spec|
  spec.name          = "form_objects"
  spec.version       = FormObjects::VERSION
  spec.authors       = ["Piotr Nielacny", "Przemek Lusar"]
  spec.email         = ["piotr.nielacny@gmail.com", "przemyslaw.lusar@gmail.com"]
  spec.description   = %q{Micro library for creating and managing complex forms}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/lluzak/form_objects"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "virtus", "~> 1.0"
  spec.add_dependency "activemodel", ">= 3.2"
  spec.add_dependency "activesupport", ">= 3.2"
end
