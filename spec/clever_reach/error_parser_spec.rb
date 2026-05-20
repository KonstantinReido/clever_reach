require "spec_helper"

RSpec.describe CleverReach::ErrorParser do
  describe ".message" do
    it "uses message before other error fields" do
      body = {
        "message" => "Message",
        "error_description" => "Description",
        "error" => "Error"
      }.to_json

      expect(described_class.message(body)).to eq("Message")
    end

    it "uses error_description before error" do
      body = {
        "error_description" => "Description",
        "error" => "Error"
      }.to_json

      expect(described_class.message(body)).to eq("Description")
    end

    it "uses error when no richer field exists" do
      expect(described_class.message({ "error" => "Error" }.to_json)).to eq("Error")
    end

    it "returns raw non-JSON bodies" do
      expect(described_class.message("plain error")).to eq("plain error")
    end

    it "returns fallback for blank bodies" do
      expect(described_class.message(" \n", "HTTP 500")).to eq("HTTP 500")
    end
  end
end
