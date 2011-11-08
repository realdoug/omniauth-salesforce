require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Salesforce < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site          => 'https://login.salesforce.com',
        :authorize_url => '/services/oauth2/authorize',
        :token_url     => '/services/oauth2/token'
      }
      def request_phase
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
          'image'           => raw_info['nick_name'],
          'phone'           => '',
          'urls'            => raw_info['urls'],
          'organizationid'  => raw_info['organization_id'],
          'userid'          => raw_info['user_id'],
          'username'        => raw_info['username'],
          'organization_id' => raw_info['organization_id'],
          'user_id'         => raw_info['user_id'],
          'user_name'       => raw_info['username']
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = :oauth_token
        @raw_info ||= access_token.post(access_token['id']).parsed
      end
    end
  end
end