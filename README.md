# omniauth-salesforce

[OmniAuth](https://github.com/intridea/omniauth) Strategy for [salesforce.com](salesforce.com).


[http://omniauth-salesforce-example.herokuapp.com](http://omniauth-salesforce-example.herokuapp.com) <== demo app

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
