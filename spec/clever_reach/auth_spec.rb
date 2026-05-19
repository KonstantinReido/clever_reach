require "spec_helper"

RSpec.describe CleverReach::Auth do
  subject(:auth) { described_class.new(CleverReach.configuration) }

  let(:token_url) { "https://rest.cleverreach.com/oauth/token.php" }

  describe "#token" do
    it "requests a client credentials token" do
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
      expect(auth.expires_at).to be > Time.now
    end

    it "uses the configured auth URL" do
      CleverReach.configuration.auth_url = "https://auth.example.test/oauth/token"

      stub_request(:post, "https://auth.example.test/oauth/token")
        .to_return(status: 200, body: { access_token: "custom", expires_in: 3600 }.to_json)

      expect(auth.token).to eq("custom")
    end

    it "reuses a valid cached token" do
      stub_request(:post, token_url)
        .to_return(status: 200, body: { access_token: "cached", expires_in: 3600 }.to_json)

      expect(auth.token).to eq("cached")
      expect(auth.token).to eq("cached")

      expect(WebMock).to have_requested(:post, token_url).once
    end

    it "refreshes an expired token" do
      stub_request(:post, token_url)
        .to_return(
          { status: 200, body: { access_token: "first", expires_in: 1 }.to_json },
          { status: 200, body: { access_token: "second", expires_in: 3600 }.to_json }
        )

      expect(auth.token).to eq("first")
      expect(auth.token).to eq("second")

      expect(WebMock).to have_requested(:post, token_url).twice
    end

    it "raises AuthenticationError for failed authentication responses" do
      stub_request(:post, token_url)
        .to_return(status: 401, body: { error: "invalid_client" }.to_json)

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, /Authentication failed with status 401/)
    end

    it "raises AuthenticationError for invalid JSON success responses" do
      stub_request(:post, token_url)
        .to_return(status: 200, body: "not json")

      expect { auth.token }
        .to raise_error(CleverReach::AuthenticationError, /Failed to parse authentication response:/)
    end
  end
end
