source 'https://rubygems.org'

# Specify your gem's dependencies in omniauth-salesforce.gemspec
gemspec

group :test do
  gem 'rake'
  gem 'rspec', '>= 2.14'
  gem 'simplecov', :require => false
  gem 'coveralls', :require => false
end

group :local_development do
  gem 'terminal-notifier-guard', require: false
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'guard-preek', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-cane', require: false
  gem 'guard-reek', github: 'pericles/guard-reek', require: false
  gem 'pry'
end
