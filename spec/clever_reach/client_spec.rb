require "spec_helper"
require "clever_reach/client"

RSpec.describe CleverReach::Client do
  it "keeps the legacy client constant usable without Faraday" do
    expect(described_class).to be < CleverReach::NetHttpClient
  end
end

RSpec.describe CleverReach::NetHttpClient do
  let(:client) { described_class.new }

  describe "#initialize" do
    context "with valid configuration" do
      it "initializes successfully" do
        expect(client).to be_a(described_class)
        expect(client.auth).to be_a(CleverReach::Auth)
      end
    end

    context "without client_id" do
      before do
        CleverReach.configure do |config|
          config.client_id = nil
          config.client_secret = "test_secret"
        end
      end

      it "raises ConfigurationError" do
        expect { described_class.new }.to raise_error(CleverReach::ConfigurationError, "Client ID is required")
      end
    end

    context "without client_secret" do
      before do
        CleverReach.configure do |config|
          config.client_id = "test_id"
          config.client_secret = nil
        end
      end

      it "raises ConfigurationError" do
        expect { described_class.new }.to raise_error(CleverReach::ConfigurationError, "Client Secret is required")
      end
    end

    context "with blank credentials" do
      before do
        CleverReach.configure do |config|
          config.client_id = " "
          config.client_secret = "test_secret"
        end
      end

      it "raises ConfigurationError" do
        expect { described_class.new }.to raise_error(CleverReach::ConfigurationError, "Client ID is required")
      end
    end
  end

  describe "#groups" do
    it "returns a Groups resource" do
      expect(client.groups).to be_a(CleverReach::Resources::Groups)
    end

    it "memoizes the groups resource" do
      expect(client.groups).to be(client.groups)
    end
  end

  describe "resources" do
    it "returns and memoizes resource objects" do
      resource_expectations = {
        attributes: CleverReach::Resources::Attributes,
        blacklist: CleverReach::Resources::Blacklist,
        bounces: CleverReach::Resources::Bounces,
        clients: CleverReach::Resources::Clients,
        debug: CleverReach::Resources::Debug,
        forms: CleverReach::Resources::Forms,
        mailings: CleverReach::Resources::Mailings,
        my_content: CleverReach::Resources::MyContent,
        oauth: CleverReach::Resources::Oauth,
        reports: CleverReach::Resources::Reports
      }

      resource_expectations.each do |method_name, resource_class|
        expect(client.public_send(method_name)).to be_a(resource_class)
        expect(client.public_send(method_name)).to be(client.public_send(method_name))
      end
    end
  end

  describe "#recipients" do
    it "returns a Recipients resource" do
      expect(client.recipients).to be_a(CleverReach::Resources::Recipients)
    end

    it "memoizes the recipients resource" do
      expect(client.recipients).to be(client.recipients)
    end
  end

  describe "#get" do
    before do
      allow(client.auth).to receive(:token).and_return("test_token")
    end

    it "returns parsed JSON for successful responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .with(headers: { "Authorization" => "Bearer test_token" })
        .to_return(
          status: 200,
          body: [{ id: 1, name: "Newsletter" }].to_json,
          headers: { "Content-Type" => "application/json" }
        )

      expect(client.get("/groups")).to eq([{ "id" => 1, "name" => "Newsletter" }])
    end

    it "returns nil for successful whitespace-only responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 200, body: " \n\t")

      expect(client.get("/groups")).to be_nil
    end

    it "uses the configured user agent" do
      client.configuration.user_agent = "My App"

      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .with(headers: { "User-Agent" => "My App" })
        .to_return(status: 200, body: [].to_json)

      expect(client.get("/groups")).to eq([])
    end

    it "sends query params for GET requests" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups/1/receivers?page=2")
        .to_return(status: 200, body: [].to_json)

      client.get("/groups/1/receivers", page: 2)

      expect(WebMock).to have_requested(:get, "https://rest.cleverreach.com/v3/groups/1/receivers?page=2")
    end

    it "preserves existing query params when adding GET params" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups/1/receivers?active=true&page=2")
        .to_return(status: 200, body: [].to_json)

      client.get("/groups/1/receivers?active=true", page: 2)

      expect(WebMock)
        .to have_requested(:get, "https://rest.cleverreach.com/v3/groups/1/receivers?active=true&page=2")
    end

    it "uses the configured API base URL" do
      client.configuration.api_base_url = "http://api.example.test/v3"

      stub_request(:get, "http://api.example.test/v3/groups")
        .to_return(status: 200, body: [].to_json)

      expect(client.get("/groups")).to eq([])
    end

    it "raises ConfigurationError for relative API base URLs" do
      client.configuration.api_base_url = "/v3"

      expect { client.get("/groups") }
        .to raise_error(CleverReach::ConfigurationError, "API base URL must be an absolute HTTP or HTTPS URL")
    end

    it "raises ConfigurationError for malformed API base URLs" do
      client.configuration.api_base_url = "https://exa mple.test/v3"

      expect { client.get("/groups") }
        .to raise_error(CleverReach::ConfigurationError, /API base URL is invalid:/)
    end

    it "raises ConfigurationError for API base URLs with query params" do
      client.configuration.api_base_url = "https://api.example.test/v3?region=eu"

      expect { client.get("/groups") }
        .to raise_error(CleverReach::ConfigurationError, "API base URL must not include query parameters or fragments")
    end

    it "normalizes trailing slashes in the configured API base URL" do
      client.configuration.api_base_url = "http://api.example.test/v3/"

      stub_request(:get, "http://api.example.test/v3/groups")
        .to_return(status: 200, body: [].to_json)

      expect(client.get("/groups")).to eq([])
    end

    it "accepts request paths without a leading slash" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 200, body: [].to_json)

      expect(client.get("groups")).to eq([])
    end

    it "raises ValidationError for 400 responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 400, body: { message: "Invalid request" }.to_json)

      expect { client.get("/groups") }
        .to raise_error(CleverReach::ValidationError, "Invalid request")
    end

    it "uses error descriptions from API error responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 400, body: { error_description: "Detailed validation failure" }.to_json)

      expect { client.get("/groups") }
        .to raise_error(CleverReach::ValidationError, "Detailed validation failure")
    end

    it "raises AuthenticationError for 401 responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 401, body: { error: "invalid_token" }.to_json)

      expect { client.get("/groups") }
        .to raise_error(CleverReach::AuthenticationError, "Unauthorized: invalid_token")
    end

    it "raises NotFoundError for 404 responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups/unknown")
        .to_return(status: 404, body: { message: "Missing" }.to_json)

      expect { client.get("/groups/unknown") }
        .to raise_error(CleverReach::NotFoundError, "Resource not found: Missing")
    end

    it "uses the status code for whitespace-only error responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups/unknown")
        .to_return(status: 404, body: " \n")

      expect { client.get("/groups/unknown") }
        .to raise_error(CleverReach::NotFoundError, "Resource not found: HTTP 404")
    end

    it "raises RateLimitError for 429 responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 429, body: { message: "Slow down" }.to_json)

      expect { client.get("/groups") }
        .to raise_error(CleverReach::RateLimitError, "Rate limit exceeded: Slow down")
    end

    it "raises APIError with response details for other error responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 500, body: { message: "Server error" }.to_json)

      expect { client.get("/groups") }
        .to raise_error(CleverReach::APIError) { |error|
          expect(error.message).to eq("API request failed: Server error")
          expect(error.status_code).to eq(500)
          expect(error.response_body).to eq({ message: "Server error" }.to_json)
        }
    end

    it "raises APIError for invalid JSON success responses" do
      stub_request(:get, "https://rest.cleverreach.com/v3/groups")
        .to_return(status: 200, body: "not json")

      expect { client.get("/groups") }
        .to raise_error(CleverReach::APIError, /Failed to parse response:/)
    end

    it "wraps TLS failures in APIError" do
      http = instance_double(Net::HTTP)
      allow(CleverReach::HTTP).to receive(:connection).and_return(http)
      allow(http).to receive(:request).and_raise(OpenSSL::SSL::SSLError, "tls alert")

      expect { client.get("/groups") }
        .to raise_error(CleverReach::APIError, "Request failed: tls alert")
    end
  end

  describe "#post" do
    before do
      allow(client.auth).to receive(:token).and_return("test_token")
    end

    it "sends JSON request bodies" do
      stub_request(:post, "https://rest.cleverreach.com/v3/groups")
        .with(
          body: { name: "Newsletter" }.to_json,
          headers: {
            "Authorization" => "Bearer test_token",
            "Content-Type" => "application/json"
          }
        )
        .to_return(status: 201, body: { id: 1, name: "Newsletter" }.to_json)

      expect(client.post("/groups", name: "Newsletter")).to eq({ "id" => 1, "name" => "Newsletter" })
    end
  end

  describe "#put" do
    before do
      allow(client.auth).to receive(:token).and_return("test_token")
    end

    it "sends JSON request bodies" do
      stub_request(:put, "https://rest.cleverreach.com/v3/groups/1")
        .with(
          body: { name: "Updated" }.to_json,
          headers: {
            "Authorization" => "Bearer test_token",
            "Content-Type" => "application/json"
          }
        )
        .to_return(status: 200, body: { id: 1, name: "Updated" }.to_json)

      expect(client.put("/groups/1", name: "Updated")).to eq({ "id" => 1, "name" => "Updated" })
    end
  end

  describe "#delete" do
    before do
      allow(client.auth).to receive(:token).and_return("test_token")
    end

    it "returns nil for successful empty responses" do
      stub_request(:delete, "https://rest.cleverreach.com/v3/groups/1")
        .with(headers: { "Authorization" => "Bearer test_token" })
        .to_return(status: 204, body: "")

      expect(client.delete("/groups/1")).to be_nil
    end

    it "sends query params for DELETE requests" do
      stub_request(:delete, "https://rest.cleverreach.com/v3/receivers/456?group_id=123")
        .to_return(status: 204, body: "")

      client.delete("/receivers/456", group_id: 123)

      expect(WebMock).to have_requested(:delete, "https://rest.cleverreach.com/v3/receivers/456?group_id=123")
    end
  end

  describe "unsupported HTTP methods" do
    it "raises APIError" do
      expect { client.send(:request, :patch, "/groups/1") }
        .to raise_error(CleverReach::APIError, "Unsupported HTTP method: patch")
    end
  end
end
