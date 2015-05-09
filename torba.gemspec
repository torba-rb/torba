Gem::Specification.new do |spec|
  spec.name          = "torba"
  spec.version       = "0.2.0"
  spec.authors       = ["Andrii Malyshko"]
  spec.email         = ["mail@nashbridges.me"]
  spec.description   = "Bundler for Sprockets"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/torba-rb/torba"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.bindir        = "bin"
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19.1"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.4"
end
