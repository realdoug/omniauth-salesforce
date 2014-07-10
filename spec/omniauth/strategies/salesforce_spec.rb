require 'spec_helper'

RSpec.describe OmniAuth::Strategies::Salesforce do
  let(:custom_site_url) { 'https://my.salesforce.com' }
  let(:custom_authorize_url) { '/oauth2/authorize' }
  let(:custom_token_url) { '/custom/token' }
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}, user_agent: 'default') }

  before do
    ::OmniAuth.config.test_mode = true
  end

  after do
    ::OmniAuth.config.test_mode = false
  end

  subject do
    args = ['appid', 'secret', @options || {}].compact
    described_class.new(*args).tap do |strategy|
      allow(strategy).to receive(:request) {
        request
      }
    end
  end

  describe '#client_options' do
    it 'should have correct name' do
      expect(subject.options.name).to eq('salesforce')
    end

    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://login.salesforce.com')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('/services/oauth2/authorize')
    end

    it 'should have correct token url' do
      expect(subject.options.client_options.token_url).to eq('/services/oauth2/token')
    end

    describe 'should be overridable' do
      it 'for site' do
        @options = { client_options: { site: custom_site_url } }
        expect(subject.options.client_options.site).to eq(custom_site_url)
      end

      it 'for authorize url' do
        @options = { client_options: { authorize_url: custom_authorize_url } }
        expect(subject.options.client_options.authorize_url).to eq(custom_authorize_url)
      end

      it 'for token url' do
        @options = { client_options: { token_url: custom_token_url } }
        expect(subject.options.client_options.token_url).to eq(custom_token_url)
      end
    end
  end

  describe 'authorize_params' do
    it 'should include default value for display' do
      expect(subject.authorize_params).to include({display: 'page'})
    end
    context 'when using a mobile browser' do
      user_agents = {
        Pre: 'Mozilla/5.0 (webOS/1.4.0; U; en-US) AppleWebKit/532.2 (KHTML, like Gecko) Version/1.0 Safari/532.2 Pre/1.1',
        iPod: 'Mozilla/5.0 (iPod; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/4A93 Safari/419.3',
        iPhone: 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3',
        iPad: 'Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10',
        Nexus: 'Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
        myTouch: 'Mozilla/5.0 (Linux; U; Android 1.6; en-us; WOWMobile myTouch 3G Build/unknown) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1',
        Storm: 'BlackBerry9530/4.7.0.148 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/105',
        Torch: 'Mozilla/5.0 (BlackBerry; U; BlackBerry 9810; en-US) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.0.0 Mobile Safari/534.11+',
        generic_mobile: 'some mobile device'
      }
      user_agents.each_pair do |name, agent|
        context "with the user agent from a #{name}" do
          before do
            allow(request).to receive(:user_agent).and_return(agent)
          end
          it 'should set display value to "touch"' do
            expect(subject.authorize_params).to include({display: 'touch'})
          end
        end
      end
    end
    context 'when using a desktop browser' do
      user_agents = {
        Chrome: 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.21 (KHTML, like Gecko) Chrome/19.0.1042.0 Safari/535.21',
        Safari: 'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1',
        IE: 'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 1.0.3705; .NET CLR 1.1.4322)',
        anything_else: 'unknown'
      }
      user_agents.each_pair do |name, agent|
        context "with the user agent from #{name}" do
          before do
            allow(request).to receive(:user_agent).and_return(agent)
          end
          it 'should set display value to "page"' do
            expect(subject.authorize_params).to include({display: 'page'})
          end
        end
      end
    end
  end

  describe '#authorize_options' do
    %w(scope display immediate state prompt login_hint response_type).each do |k|
      it "should support #{k}" do
        @options = {k => 'someval'}
        expect(subject.authorize_params[k.to_s]).to eq('someval')
      end
    end
    describe 'scope' do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['scope']).to eq(nil)
      end

      it 'should set scope parameter if present' do
        @options = { scope: 'some value' }
        expect(subject.authorize_params['scope']).to eq('some value')
      end
    end
    describe 'prompt' do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['prompt']).to eq(nil)
      end

      it 'should set prompt parameter if present' do
        @options = { prompt: 'some value' }
        expect(subject.authorize_params['prompt']).to eq('some value')
      end
    end
    describe 'login_hint' do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['login_hint']).to eq(nil)
      end

      it 'should set login_hint parameter if present' do
        @options = { login_hint: 'some value' }
        expect(subject.authorize_params['login_hint']).to eq('some value')
      end
    end
    describe 'response_type' do
      it 'should default to code' do
        @options = {}
        expect(subject.authorize_params['response_type']).to eq('code')
      end

      it 'should set response_type parameter if present' do
        @options = { response_type: 'some value' }
        expect(subject.authorize_params['response_type']).to eq('some value')
      end
    end
    describe 'immediate' do
      it 'should default to nil' do
        @options = {}
        expect(subject.authorize_params['immediate']).to eq(nil)
      end

      it 'should set immediate parameter if present' do
        @options = { immediate: 'some value' }
        expect(subject.authorize_params['immediate']).to eq('some value')
      end
    end
    describe 'state' do
      it 'should set the state parameter' do
        @options = {:state => 'some_state'}
        expect(subject.authorize_params['state']).to eq('some_state')
        expect(subject.session['omniauth.state']).to eq('some_state')
      end

      it 'should set the omniauth.state dynamically' do
        allow(subject).to receive(:request) { double('Request', {:params => {'state' => 'some_state'}, :env => {}, user_agent: 'default'}) }
        expect(subject.authorize_params['state']).to eq('some_state')
        expect(subject.session['omniauth.state']).to eq('some_state')
      end
    end
  end

  describe 'callback phase' do
    raw_info = nil
    before do
      raw_info = {
        'id' => 'salesforce id',
        'display_name' => 'display name',
        'email' => 'email',
        'nick_name' => 'nick name',
        'first_name' => 'first name',
        'last_name' => 'last name',
        'photos' => {'thumbnail' => '/thumbnail/url'},
        'urls' => {
          'enterprise' => 'https://salesforce.example/services',
          'metadata' => 'https://salesforce.example/services'
        }
      }
      client = OAuth2::Client.new 'id', 'secret', site: 'example.com'
      access_token = OAuth2::AccessToken.from_hash client,
                                                   'access_token' => 'token',
                                                   'instance_url' => 'http://instance.salesforce.example',
                                                   'signature' => 'invalid',
                                                   'issued_at' => '1296458209517'

      allow(strategy).to receive(:raw_info) { raw_info }
      allow(strategy).to receive(:access_token) { access_token }
    end
    describe 'uid' do
      it 'sets the id' do
        expect(strategy.uid).to eq(raw_info['id'])
      end
    end
    describe 'info' do
      subject { strategy.info }
      it 'returns an info hash' do
        expect(subject).not_to be_nil
      end
      it 'sets name' do
        expect(subject['name']).to eq(raw_info['display_name'])
      end
      it 'sets email' do
        expect(subject['email']).to eq(raw_info['email'])
      end
      it 'sets nickname' do
        expect(subject['nickname']).to eq(raw_info['nick_name'])
      end
      it 'sets first_name' do
        expect(subject['first_name']).to eq(raw_info['first_name'])
      end
      it 'sets last_name' do
        expect(subject['last_name']).to eq(raw_info['last_name'])
      end
      it 'sets location' do
        expect(subject['location']).to eq('')
      end
      it 'sets description' do
        expect(subject['description']).to eq('')
      end
      it 'sets image' do
        expect(subject['image']).to eq(raw_info['photos']['thumbnail'] + "?oauth_token=#{strategy.access_token.token}")
      end
      it 'sets phone' do
        expect(subject['phone']).to eq('')
      end
      it 'sets urls' do
        expect(subject['urls']).to eq(raw_info['urls'])
      end
    end
    describe 'credentials' do
      subject { strategy.credentials }
      it 'sets token' do
        expect(subject['token']).to eq(strategy.access_token.token)
      end
      it 'sets instance_url' do
        expect(subject['instance_url']).to eq(strategy.access_token.params['instance_url'])
      end
      context 'given a refresh token' do
        it 'sets refresh_token' do
          expect(subject['refresh_token']).to eq(strategy.access_token.refresh_token)
        end
      end
      context 'when not given a refresh token' do
        it 'does not set a refresh token' do
          expect(subject['refresh_token']).to be_nil
        end
      end
    end
    describe 'extra' do
      subject { strategy.extra }
      it 'sets instance_url' do
        expect(subject['instance_url']).to eq(strategy.access_token.params['instance_url'])
      end
      it 'sets pod' do
        expect(subject['pod']).to eq(strategy.access_token.params['instance_url'])
      end
      it 'sets signature' do
        expect(subject['signature']).to eq(strategy.access_token.params['signature'])
      end
      it 'sets issued_at' do
        expect(subject['issued_at']).to eq(strategy.access_token.params['issued_at'])
      end
    end
    describe 'user id validation' do
      client_id = nil
      issued_at = nil
      signature = nil
      instance_url = 'http://instance.salesforce.example'
      before do
        client_id = 'https://login.salesforce.com/id/00Dd0000000d45TEBQ/005d0000000fyGPCCY'
        issued_at = '1331142541514'
        signature = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', strategy.options.client_secret.to_s, client_id + issued_at))
      end
      context 'when the signature does not match' do
        before do
          access_token = OAuth2::AccessToken.from_hash strategy.access_token.client,
                                                       'id' => 'forged client id',
                                                       'issued_at' => issued_at,
                                                       'instance_url' => 'http://instance.salesforce.example',
                                                       'signature' => signature

          allow(strategy).to receive(:access_token) { access_token }
        end
        it 'should call fail!' do
          expect(strategy).to receive(:fail!)
          strategy.auth_hash
        end
      end
      context 'when the signature does match' do
        before do
          access_token = OAuth2::AccessToken.from_hash strategy.access_token.client,
                                                       'id' => client_id,
                                                       'issued_at' => issued_at,
                                                       'instance_url' => 'http://instance.salesforce.example',
                                                       'signature' => signature

          allow(strategy).to receive(:access_token) { access_token }
        end
        it 'should not fail' do
          expect(strategy).not_to receive(:fail!)
          strategy.auth_hash
        end
      end
    end
  end
end
