require "spec_helper"

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
  end

  describe "#groups" do
    it "returns a Groups resource" do
      expect(client.groups).to be_a(CleverReach::Resources::Groups)
    end

    it "memoizes the groups resource" do
      expect(client.groups).to be(client.groups)
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
end
