require "spec_helper"

RSpec.describe CleverReach do
  describe ".configuration" do
    it "returns a Configuration object" do
  expect(described_class.configuration).to be_a(CleverReach::Configuration)
    end
  end

  describe ".configure" do
    it "allows setting configuration options" do
      described_class.configure do |config|
        config.client_id = "new_client_id"
        config.client_secret = "new_client_secret"
        config.api_base_url = "https://custom.api.com"
      end

      expect(described_class.configuration.client_id).to eq("new_client_id")
      expect(described_class.configuration.client_secret).to eq("new_client_secret")
      expect(described_class.configuration.api_base_url).to eq("https://custom.api.com")
    end
  end

  describe ".reset_configuration!" do
    before do
      described_class.configure do |config|
        config.client_id = "test_id"
      end
    end

    it "resets configuration to defaults" do
      described_class.reset_configuration!
      expect(described_class.configuration.client_id).to be_nil
      expect(described_class.configuration.api_base_url).to eq("https://rest.cleverreach.com/v3")
    end
  end
end
