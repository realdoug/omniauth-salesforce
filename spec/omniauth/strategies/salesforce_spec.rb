require 'spec_helper'

describe OmniAuth::Strategies::Salesforce do
  let(:rack_app) do
    rack_app = double('rack_app')
    rack_app.stub(:call)
    rack_app
  end
  let(:strategy) { OmniAuth::Strategies::Salesforce.new rack_app, 'Consumer Key', 'Consumer Secret' }
  let(:access_token) { OAuth2::AccessToken.from_hash client, access_token_params }
  let(:access_token_params) do
    {
      'id' => client_id,
      'access_token' => client_id,
      'instance_url' => instance_url,
      'signature' => signature,
      'issued_at' => issued_at
    }
  end
  let(:client_id) { "https://login.salesforce.com/id/00Dd0000000d45TEBQ/005d0000000fyGPCCY" }
  let(:signature) { Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', strategy.options.client_secret, client_id + issued_at)) }
  let(:instance_url) { 'http://instance.salesforce.example' }
  let(:issued_at) { '1296458209517' }

  subject { strategy }

  before(:each) { OmniAuth.config.test_mode = true }

  describe "request_phase" do
    let(:env) do
      env = {
        'rack.session' => {},
        'HTTP_USER_AGENT' => 'unknown',
        'REQUEST_METHOD' => 'GET',
        'rack.input' => '',
        'rack.url_scheme' => 'http',
        'SERVER_NAME' => 'server.example',
        'QUERY_STRING' => 'code=xxxx',
        'SCRIPT_NAME' => '',
        'SERVER_PORT' => 80
      }
    end

    before(:each) do
      env['HTTP_USER_AGENT'] = agent
      strategy.call!(env)
      strategy.request_phase
    end

    context "when using a mobile browser" do
      user_agents = {
        :Pre => "Mozilla/5.0 (webOS/1.4.0; U; en-US) AppleWebKit/532.2 (KHTML, like Gecko) Version/1.0 Safari/532.2 Pre/1.1",
        :iPod => "Mozilla/5.0 (iPod; U; CPU like Mac OS X; en) AppleWebKit/420.1 (KHTML, like Gecko) Version/3.0 Mobile/4A93 Safari/419.3",
        :iPhone => "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543 Safari/419.3",
        :iPad => "Mozilla/5.0 (iPad; U; CPU OS 3_2 like Mac OS X; en-us) AppleWebKit/531.21.10 (KHTML, like Gecko) Version/4.0.4 Mobile/7B334b Safari/531.21.10",
        :Nexus => "Mozilla/5.0 (Linux; U; Android 2.2; en-us; Nexus One Build/FRF91) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1",
        :myTouch => "Mozilla/5.0 (Linux; U; Android 1.6; en-us; WOWMobile myTouch 3G Build/unknown) AppleWebKit/528.5+ (KHTML, like Gecko) Version/3.1.2 Mobile Safari/525.20.1",
        :Storm => "BlackBerry9530/4.7.0.148 Profile/MIDP-2.0 Configuration/CLDC-1.1 VendorID/105",
        :Torch => "Mozilla/5.0 (BlackBerry; U; BlackBerry 9810; en-US) AppleWebKit/534.11+ (KHTML, like Gecko) Version/7.0.0 Mobile Safari/534.11+",
        :generic_mobile => "some mobile device"
      }
      user_agents.each_pair do |name, agent|
        context "with the user agent #{name.to_s}" do
          let(:agent) { agent }
          subject {strategy.options}
          its([:display]) { should == 'touch' }
        end
      end
    end

    context "when using a desktop browser" do
      user_agents = {
        :Chrome => "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.21 (KHTML, like Gecko) Chrome/19.0.1042.0 Safari/535.21",
        :Safari => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1",
        :IE => "Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 1.0.3705; .NET CLR 1.1.4322)",
        :anything_else => "unknown"
      }
      user_agents.each_pair do |name, agent|
        context "with the user agent #{name.to_s}" do
          let(:agent) { agent }
          subject {strategy.options}
          its([:display]) { should == 'page' }
        end
      end
    end
  end
  describe "callback phase" do
    let(:raw_info) do
      {
        'id' => 'salesforce id',
        'display_name' => 'display name',
        'email' => 'email',
        'nick_name' => 'nick name',
        'first_name' => 'first name',
        'last_name' => 'last name',
        'photos' => {'thumbnail' => '/thumbnail/url'},
        'urls'=> {
          "enterprise" => "https://salesforce.example/services",
          "metadata" => "https://salesforce.example/services"
        }
      }
    end
    let(:client) { OAuth2::Client.new 'id', 'secret', {:site => 'example.com'} }

    before(:each) do
      strategy.stub(:raw_info) { raw_info }
      strategy.stub(:access_token) { access_token }
    end

    describe "uid" do
      its(:uid) { should == raw_info['id'] }
    end

    describe "info" do
      subject { strategy.info }

      it { should_not be_nil }
      its(['name']) { should == raw_info['display_name'] }
      its(['email']) { should == raw_info['email'] }
      its(['nickname']) { should == raw_info['nick_name'] }
      its(['first_name']) { should == raw_info['first_name'] }
      its(['last_name']) { should == raw_info['last_name'] }
      its(['first_name']) { should == raw_info['first_name'] }
      its(['location']) { should == '' }
      its(['description']) { should == '' }
      its(['image']) { should == raw_info['photos']['thumbnail'] + "?oauth_token=#{strategy.access_token.token}" }
      its(['phone']) { should == '' }
      its(['urls']) { should == raw_info['urls'] }
    end

    describe "credentials" do
      subject { strategy.credentials }

      its(['token']) { should == strategy.access_token.token }
      its(['instance_url']) { should == strategy.access_token.params['instance_url'] }

      context "given a refresh token" do
        let(:access_token) { OAuth2::AccessToken.from_hash client, {'refresh_token' => 'refreash_token'} }

        its(['refresh_token']) { should == access_token.refresh_token }
        its(['refresh_token']) { should_not be_empty }
      end

      context "when not given a refresh token" do
        its(['refresh_token']) { should be_nil }
      end
    end

    describe "extra" do
      subject { strategy.extra }

      its(['instance_url']) { should == access_token.params['instance_url'] }
      its(['pod']) { should == access_token.params['instance_url'] }
      its(['signature']) { should == access_token.params['signature'] }
      its(['issued_at']) { should == access_token.params['issued_at'] }
    end

    describe "user id validation" do
      context "when the signature does not match" do
        let(:access_token) { OAuth2::AccessToken.from_hash client, access_token_params.merge('id' => 'forged client id') }

        it "should call fail!" do
          strategy.should_receive(:fail!)
          strategy.auth_hash
        end
      end

      context "when the signature does match" do
        it "should not fail" do
          strategy.should_not_receive(:fail!)
          strategy.auth_hash
        end
      end
    end
  end
end
