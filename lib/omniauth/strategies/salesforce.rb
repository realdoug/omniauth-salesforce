require 'omniauth-oauth2'
require 'openssl'
require 'base64'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2
      MOBILE_USER_AGENTS = 'webos|ipod|iphone|ipad|android|blackberry|mobile'
      FAIL_MESSAGE = 'Salesforce user id did not match signature!'
      PARAMS_KEYS = %w(display scope state prompt immediate login_hint response_type)

      option :name, 'salesforce'

      option :client_options,
             site: 'https://login.salesforce.com',
             authorize_url: '/services/oauth2/authorize',
             token_url: '/services/oauth2/token'

      option :authorize_options, PARAMS_KEYS.map(&:to_sym)

      def authorize_params
        super.tap do |params|
          PARAMS_KEYS.each do |key|
            next unless request.params[key]
            params[key.to_sym] = request.params[key]
          end
          params[:display] ||= default_display_value
          params[:response_type] ||= 'code'
          session['omniauth.state'] = params[:state] if params['state']
        end
      end

      def default_display_value
        ua = request.user_agent.to_s.downcase
        mobile_request = ua =~ Regexp.new(MOBILE_USER_AGENTS)
        mobile_request ? 'touch' : 'page'
      end

      def auth_hash
        fail! FAIL_MESSAGE unless valid_signature?
        super
      end

      def valid_signature?
        raw_expected_signature =
          OpenSSL::HMAC.digest('sha256', options.client_secret.to_s, signed_value)
        expected_signature = Base64.strict_encode64(raw_expected_signature)
        access_token.params['signature'] == expected_signature
      end

      def signed_value
        access_token.params['id'] + access_token.params['issued_at']
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'name' => raw_info['display_name'],
          'email' => raw_info['email'],
          'nickname' => raw_info['nick_name'],
          'first_name' => raw_info['first_name'],
          'last_name' => raw_info['last_name'],
          'location' => '',
          'description' => '',
          'image' => raw_info['photos']['thumbnail'] +
                     "?oauth_token=#{access_token.token}",
          'phone' => '',
          'urls' => raw_info['urls']
        }
      end

      credentials do
        hash = { 'token' => access_token.token }
        hash.merge!('instance_url' => access_token.params['instance_url'])
        hash.merge!('refresh_token' => access_token.refresh_token) if access_token.refresh_token
        hash
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :oauth_token
        @raw_info ||= access_token.post(access_token['id']).parsed
      end

      extra do
        raw_info.merge(
          'instance_url' => access_token.params['instance_url'],
          'pod' => access_token.params['instance_url'],
          'signature' => access_token.params['signature'],
          'issued_at' => access_token.params['issued_at']
        )
      end
    end

    class SalesforceSandbox < OmniAuth::Strategies::Salesforce
      default_options[:name] = 'salesforce_sandbox'
      default_options[:client_options][:site] = 'https://test.salesforce.com'
    end

    class DatabaseDotCom < OmniAuth::Strategies::Salesforce
      default_options[:name] = 'database_com'
      default_options[:client_options][:site] = 'https://login.database.com'
    end

    class SalesforcePreRelease < OmniAuth::Strategies::Salesforce
      default_options[:name] = 'salesforce_prerelease'
      default_options[:client_options][:site] = 'https://prerellogin.pre.salesforce.com/'
    end
  end
end
