# omniauth-salesforce

[OmniAuth](https://github.com/intridea/omniauth) Strategy for [salesforce.com](salesforce.com).

[![Build Status](https://travis-ci.org/dotpromo/omniauth-salesforce.svg?branch=master)](https://travis-ci.org/dotpromo/omniauth-salesforce)
[![Coverage Status](https://coveralls.io/repos/dotpromo/omniauth-salesforce/badge.png)](https://coveralls.io/r/dotpromo/omniauth-salesforce)[![Code Climate](https://codeclimate.com/github/dotpromo/omniauth-salesforce.png)](https://codeclimate.com/github/dotpromo/omniauth-salesforce)

Note: This is a fork of the [original](https://github.com/richardvanhook/omniauth-salesforce) project and is now the main repository for the omniauth-salesforce gem.

## See it in action

[http://omniauth-salesforce-example.herokuapp.com](http://omniauth-salesforce-example.herokuapp.com)

[Source for above app](https://github.com/richardvanhook/omniauth-salesforce-example)

## Sinatra Usage

```ruby
require "sinatra"
require "omniauth"
require "omniauth-salesforce"

class MyApplication < Sinatra::Base
  use Rack::Session
  use OmniAuth::Builder do
    provider :salesforce, ENV['SALESFORCE_KEY'], ENV['SALESFORCE_SECRET']
  end
end
```

## Rails Usage

Create `config/initializers/omniauth.rb` with following content:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :salesforce, ENV['SALESFORCE_KEY'], ENV['SALESFORCE_SECRET']
end
```

## Options

* `display` - Tailors the login page to the user's device type. Currently the only values supported are:
  * `page` - Full-page authorization screen (default).
  * `popup` - Compact dialog optimized for modern web browser popup windows.
  * `touch` - mobile-optimized dialog designed for modern smartphones, such as Android and iPhone.
  * `mobile` - mobile optimized dialog designed for less capable smartphones such as BlackBerry OS 5.
  By default it set into `touch` or `page` depending on device.
* `scope` - A space separated list of scope values. The scope parameter allows you to fine-tune the permissions associated with the tokens you are requesting, selecting a subset of the values you specified when defining the connected app.
* `state` - Any value that you wish to be sent with the callback.
* `immediate` - Avoid interacting with the user.
  * `false` - Prompt the user for login and approval (default).
  * `true` - If the user is currently logged in and has previously approved the client_id, the approval step is skipped, and the browser is immediately redirected to the callback with an authorization code. If the user is not logged in or has not previously approved the client, the flow immediately terminates with the `immediate_unsuccessful` error code.
* `prompt` - Specifies how the authorization server prompts the user for reauthentication and reapproval. This parameter is optional. The only values Salesforce supports are:
  * `login` — The authorization server must prompt the user for reauthentication, forcing the user to log in again.
  * `consent` — The authorization server must prompt the user for reapproval before returning information to the client.
It is valid to pass both values, separated by a space, to require the user to both log in and reauthorize. For example:
`?prompt=login%20consent`
* `login_hint` - Provide a valid username value with this parameter to pre-populate the login page with the username. For example: `login_hint=username@company.com`. If a user already has an active session in the browser, then the login_hint parameter does nothing; the active user session continues

## Including other sites

```ruby
use OmniAuth::Builder do
    provider :salesforce,
             ENV['SALESFORCE_KEY'],
             ENV['SALESFORCE_SECRET']
    provider :salesforce_sandbox,
             ENV['SALESFORCE_SANDBOX_KEY'],
             ENV['SALESFORCE_SANDBOX_SECRET']
    provider :database_com,
             ENV['SALESFORCE_PRERELEASE_KEY'],
             ENV['SALESFORCE_PRERELEASE_SECRET']
    provider :salesforce_prerelease,
             ENV['DATABASE_DOT_COM_KEY'],
             ENV['DATABASE_DOT_COM_SECRET']
end
```

## Resources

* [Article: Digging Deeper into OAuth 2.0 on Force.com](http://wiki.developerforce.com/index.php/Digging_Deeper_into_OAuth_2.0_on_Force.com)
