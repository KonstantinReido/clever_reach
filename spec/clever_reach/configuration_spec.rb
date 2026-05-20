require "spec_helper"

RSpec.describe CleverReach::Configuration do
  let(:config) { described_class.new }

  describe "#initialize" do
    it "sets default values" do
      expect(config.api_base_url).to eq("https://rest.cleverreach.com/v3")
      expect(config.auth_url).to eq("https://rest.cleverreach.com/oauth/token.php")
      expect(config.timeout).to eq(30)
      expect(config.open_timeout).to eq(30)
      expect(config.user_agent).to eq("CleverReach Ruby Gem #{CleverReach::VERSION}")
      expect(config.clock.call).to be_a(Time)
    end
  end

  describe "#valid?" do
    context "when client_id and client_secret are set" do
      before do
        config.client_id = "test_id"
        config.client_secret = "test_secret"
      end

      it "returns true" do
        expect(config.valid?).to be true
      end
    end

    context "when client_id is missing" do
      before do
        config.client_secret = "test_secret"
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end

    context "when client_secret is missing" do
      before do
        config.client_id = "test_id"
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end

    context "when credentials are blank strings" do
      before do
        config.client_id = " "
        config.client_secret = ""
      end

      it "returns false" do
        expect(config.valid?).to be false
      end
    end
  end
end
