## Basic Usage

<blockquote>
    <p>For example.</p>
</blockquote>

use OmniAuth::Builder do
  provider :salesforce, ENV['SALESFORCE_KEY'], ENV['SALESFORCE_SECRET']
end