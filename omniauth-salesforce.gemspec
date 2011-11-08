# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-salesforce/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Richard Vanhook"]
  gem.email         = ["rvanhook@salesforce.com"]
  gem.description   = %q{OmniAuth strategy for salesforce.com.}
  gem.summary       = %q{OmniAuth strategy for salesforce.com.}
  gem.homepage      = "https://github.com/richardvanhook/omniauth-salesforce"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth-salesforce"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Salesforce::VERSION

  gem.add_dependency 'omniauth', '~> 1.0'
  gem.add_dependency 'omniauth-oauth2', '~> 1.0'
  gem.add_development_dependency 'rspec', '~> 2.7'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'webmock'
end
