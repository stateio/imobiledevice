# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'imobiledevice/version'

Gem::Specification.new do |gem|
  gem.name          = "imobiledevice"
  gem.version       = Imobiledevice::VERSION
  gem.authors       = ["Max Veytsman"]
  gem.email         = ["max@state.io"]
  gem.description   = %q{Use Ruby to interact with iPhones, iPads, etc...}
  gem.summary       = %q{Ruby Bindings for libimobiledevice }
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "ffi"
end
