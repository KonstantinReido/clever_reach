require "spec_helper"

RSpec.describe CleverReach::Auth do
  subject(:auth) { described_class.new(CleverReach.configuration) }

  let(:token_url) { "https://rest.cleverreach.com/oauth/token.php" }
  let(:now) { Time.utc(2026, 5, 20, 12, 0, 0) }

  describe "#token" do
    it "requests a client credentials token" do
      CleverReach.configuration.clock = -> { now }

      stub_request(:post, token_url)
        .with(
          body: {
            "grant_type" => "client_credentials",
            "client_id" => "test_client_id",
            "client_secret" => "test_client_secret"
          },
          headers: {
            "Content-Type" => "application/x-www-form-urlencoded",
            "User-Agent" => "CleverReach Ruby Gem #{CleverReach::VERSION}"
          }
        )
        .to_return(
          status: 200,
          body: { access_token: "abc123", expires_in: 3600 }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect(auth.token).to eq("abc123")
      expect(auth.access_token).to eq("abc123")
      expect(auth.expires_at).to eq(now + 3540)
    end

    it "uses the configured user agent" do
      CleverReach.configuration.user_agent = "My App"

      stub_request(:post, token_url)
        .with(headers: { "User-Agent" => "My App" })
        .to_return(status: 200, body: { access_token: "abc123", expires_in: 3600 }.to_json)

      expect(auth.token).to eq("abc123")
    end

    it "uses the configured auth URL" do
      CleverReach.configuration.auth_url = "https://auth.example.test/oauth/token"

      stub_request(:post, "https://auth.example.test/oauth/token")
        .to_return(status: 200, body: { access_token: "custom", expires_in: 3600 }.to_json)

      expect(auth.token).to eq("custom")
    end

    it "raises ConfigurationError for relative auth URLs" do
      CleverReach.configuration.auth_url = "/oauth/token"

      expect { auth.token }
        .to raise_error(CleverReach::ConfigurationError, "Auth URL must be an absolute HTTP or HTTPS URL")
    end

    it "raises ConfigurationError for malformed auth URLs" do
      CleverReach.configuration.auth_url = "https://exa mple.test/oauth/token"

      expect { auth.token }
        .to raise_error(CleverReach::ConfigurationError, /Auth URL is invalid:/)
    end

    it "reuses a valid cached token" do
      current_time = now
      CleverReach.configuration.clock = -> { current_time }

      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: "cached", expires_in: 3600 }.to_json)

      expect(auth.token).to eq("cached")
      current_time = now + 3500
      expect(auth.token).to eq("cached")

      expect(WebMock).to have_requested(:post, token_url).once
    end

    it "refreshes an expired token" do
      current_time = now
      CleverReach.configuration.clock = -> { current_time }

      stub_request(:post, token_url)
        .to_return(
          { status: 200, body: { access_token: "first", expires_in: 3600 }.to_json },
          { status: 200, body: { access_token: "second", expires_in: 3600 }.to_json }
        )

      expect(auth.token).to eq("first")
      current_time = now + 3541
      expect(auth.token).to eq("second")

      expect(WebMock).to have_requested(:post, token_url).twice
    end

    it "keeps short-lived tokens valid until their clamped refresh margin" do
      current_time = now
      CleverReach.configuration.clock = -> { current_time }

      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: "short", expires_in: 30 }.to_json)

      expect(auth.token).to eq("short")
      expect(auth.expires_at).to eq(now + 15)

      current_time = now + 14
      expect(auth.token).to eq("short")

      expect(WebMock).to have_requested(:post, token_url).once
    end

    it "uses the default token lifetime for malformed expires_in values" do
      CleverReach.configuration.clock = -> { now }

      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: "default", expires_in: "not-a-number" }.to_json)

      expect(auth.token).to eq("default")
      expect(auth.expires_at).to eq(now + 3540)
    end

    it "uses the default token lifetime for non-positive expires_in values" do
      CleverReach.configuration.clock = -> { now }

      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: "default", expires_in: 0 }.to_json)

      expect(auth.token).to eq("default")
      expect(auth.expires_at).to eq(now + 3540)
    end

    it "raises AuthenticationError for failed authentication responses" do
      stub_request(:post, token_url)
        .to_return(status: 401, body: { error: "invalid_client" }.to_json)

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, "Authentication failed with status 401: invalid_client")
    end

    it "uses error descriptions from failed authentication responses" do
      stub_request(:post, token_url)
        .to_return(status: 401, body: { error_description: "Credentials are invalid" }.to_json)

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, "Authentication failed with status 401: Credentials are invalid")
    end

    it "raises AuthenticationError for invalid JSON success responses" do
      stub_request(:post, token_url)
        .to_return(status: 200, body: "not json")

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, /Failed to parse authentication response:/)
    end

    it "wraps TLS failures in AuthenticationError" do
      http = instance_double(Net::HTTP)
      allow(CleverReach::HTTP).to receive(:connection).and_return(http)
      allow(http).to receive(:request).and_raise(OpenSSL::SSL::SSLError, "certificate verify failed")

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, "Failed to authenticate: certificate verify failed")
    end

    it "raises AuthenticationError when a success response omits the access token" do
      stub_request(:post, token_url)
        .to_return(status: 200, body: { expires_in: 3600 }.to_json)

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, "Authentication response did not include an access token")
    end

    it "raises AuthenticationError when a success response has a blank access token" do
      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: " ", expires_in: 3600 }.to_json)

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, "Authentication response did not include an access token")
    end
  end
end
