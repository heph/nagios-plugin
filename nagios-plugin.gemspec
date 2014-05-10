# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nagios/plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "nagios-plugin"
  spec.version       = Nagios::Plugin::VERSION
  spec.authors       = ["Lookout, Inc"]
  spec.email         = ["jof@lookout.com"]
  spec.description   = %q{Nagios Plugin Helper Library}
  spec.summary       = %q{Easily write Nagios Plugins.}
  spec.homepage      = "https://github.com/lookout/nagios-plugin"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rdoc"
  spec.add_development_dependency "minitest"
end
