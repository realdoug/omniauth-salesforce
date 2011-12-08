require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2

      MOBILE_USER_AGENTS =  'webos|ipod|iphone|mobile'

      option :client_options, {
        :site          => 'https://login.salesforce.com',
        :authorize_url => '/services/oauth2/authorize',
        :token_url     => '/services/oauth2/token'
      }
      option :authorize_options, [
        :scope,
        :display,
        :immediate,
        :state
      ]

      def request_phase
        req = Rack::Request.new(@env)
        options.update(req.params)
        ua = req.user_agent.to_s
        if !options.has_key?(:display)
          mobile_request = ua.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
          options[:display] = mobile_request ? 'touch' : 'page'
        end
        super
      end

      uid { raw_info['id'] }

      info do
        {
          'name'            => raw_info['display_name'],
          'email'           => raw_info['email'],
          'nickname'        => raw_info['nick_name'],
          'first_name'      => raw_info['first_name'],
          'last_name'       => raw_info['last_name'],
          'location'        => '',
          'description'     => '',
          'image'           => raw_info['photos']['thumbnail'] + "?oauth_token=#{access_token.token}",
          'phone'           => '',
          'urls'            => raw_info['urls']
        }
      end

      credentials do
        hash = {'token' => access_token.token}
        hash.merge!('instance_url' => access_token.params["instance_url"])
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.refresh_token
        hash
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :oauth_token
        @raw_info ||= access_token.post(access_token['id']).parsed
      end

      extra do
        raw_info.merge({
          'instance_url' => access_token.params['instance_url'],
          'pod' => access_token.params['instance_url']
        })
      end
      
    end

    class SalesforceSandbox < OmniAuth::Strategies::Salesforce
      default_options[:client_options][:site] = 'https://test.salesforce.com'
    end

    class DatabaseDotCom < OmniAuth::Strategies::Salesforce
      default_options[:client_options][:site] = 'https://login.database.com'
    end

    class SalesforcePreRelease < OmniAuth::Strategies::Salesforce
      default_options[:client_options][:site] = 'https://prerellogin.pre.salesforce.com/'
    end

  end
end
