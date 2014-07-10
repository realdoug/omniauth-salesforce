lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-salesforce/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-salesforce'
  spec.version       = OmniAuth::Salesforce::VERSION
  spec.authors       = ['Richard Vanhook', 'Alexander Simonov']
  spec.email         = ['rvanhook@salesforce.com', 'alex@simonov.me']
  spec.description   = %q{OmniAuth strategy for salesforce.com.}
  spec.summary       = %q{'OmniAuth strategy for salesforce.com.}
  spec.homepage      = 'https://github.com/dotpromo/omniauth_salesforce'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'omniauth', '~> 1.2'
  spec.add_dependency 'omniauth-oauth2', '>= 1.1.2'
  spec.required_ruby_version = '~> 2.0.0'
end
