# omniauth-salesforce

[OmniAuth](https://github.com/intridea/omniauth) Strategy for [salesforce.com](salesforce.com).

## See it in action

[http://omniauth-salesforce-example.herokuapp.com](http://omniauth-salesforce-example.herokuapp.com)

[Source for above app](https://github.com/richardvanhook/omniauth-salesforce-example)

## Basic Usage

    require "sinatra"
    require "omniauth"
    require "omniauth-salesforce"

    class MyApplication < Sinatra::Base
      use Rack::Session
      use OmniAuth::Builder do
        provider :salesforce, ENV['SALESFORCE_KEY'], ENV['SALESFORCE_SECRET']
      end
    end

