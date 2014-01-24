# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "beambridge/version"

Gem::Specification.new do |spec|
  spec.name          = "beambridge"
  spec.version       = Beambridge::VERSION
  spec.authors       = ["Scott Fleckenstein", "Tom Preston-Werner"]
  spec.email         = ["mathieul@gmail.com"]
  spec.description   = %q{Asset pipeline CLI to be executed from a different language.}
  spec.summary       = %q{A command to pre-process web assets using Ruby tools, intended to be called from a different language.}
  spec.homepage      = "https://github.com/mathieul/beambridge"
  spec.license       = "Scott Fleckenstein and Tom Preston-Werner"

  # spec.required_ruby_version = "~> 1.9.3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.extensions    = ["ext/extconf.rb"]

  spec.extra_rdoc_files = ["LICENSE", "README.md"]

  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-spec"
end
