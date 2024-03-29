Gem::Specification.new do |spec|
  spec.name          = "torba"
  spec.version       = "1.2.0"
  spec.authors       = ["Andrii Malyshko"]
  spec.email         = ["mail@nashbridges.me"]
  spec.description   = "Bundler for Sprockets"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/torba-rb/torba"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).grep_v(%r{^test/})
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", ">= 0.19.1", "< 2"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.4"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "assert_dirs_equal", "~> 0.1"
end
