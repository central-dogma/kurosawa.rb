# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kurosawa/version'

Gem::Specification.new do |spec|
  spec.name          = "kurosawa"
  spec.version       = Kurosawa::VERSION
  spec.authors       = ["astrobunny"]
  spec.email         = ["admin@astrobunny.com"]

  spec.summary       = %q{kurosawa.rb}
  spec.description   = %q{Tribute to Kurosawa Ruby}
  spec.homepage      = "https://github.com/astrobunny/kurosawa.rb"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir.glob("{bin,data,lib,exe}/**/*") + %w(README.md Gemfile)
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_dependency "sinatra", "~> 1.4"
  spec.add_dependency "sinatra-contrib"

end
