# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sok/version'

Gem::Specification.new do |spec|
  spec.name          = "sok"
  spec.version       = Kabu::VERSION
  spec.authors       = ["Traver1"]
  spec.email         = ["wor1d@outlook.com"]

  spec.summary       = %q{To download and save japanese stock data from web site.}
  spec.description   = %q{}
  spec.homepage      = "https://thawing-taiga-21738.herokuapp.com"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "standalone_migrations", "~> 5.2.0"
  spec.add_development_dependency "sqlite3", "~> 1.3.11"
  spec.add_development_dependency "activerecord-import", "~> 0.18.2"
  spec.add_development_dependency "validates_timeliness", "~> 3.0"
end
