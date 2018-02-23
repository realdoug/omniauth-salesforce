require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter,
  ],
)

SimpleCov.start do
  add_filter 'spec'
  minimum_coverage(76)
end

require 'rspec'
require 'omniauth'
require 'omniauth-salesforce'

RSpec.configure do |config|
  config.extend OmniAuth::Test::StrategyMacros, type: :strategy
end
