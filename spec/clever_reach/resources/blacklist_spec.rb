require "spec_helper"

RSpec.describe CleverReach::Resources::Blacklist do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists and finds blacklist entries" do
    expect(client).to receive(:get).with("/blacklist", {}).and_return([])
    expect(client).to receive(:get).with("/blacklist/user%40example.com", {}).and_return({ "email" => "user@example.com" })

    expect(resource.all).to eq([])
    expect(resource.find("user@example.com")).to eq({ "email" => "user@example.com" })
  end

  it "creates, updates, validates, and deletes blacklist entries" do
    entry_data = { email: "user@example.com" }
    validation_data = { emails: ["user@example.com"] }

    expect(client).to receive(:post).with("/blacklist", entry_data).and_return(entry_data)
    expect(client).to receive(:put).with("/blacklist", entry_data).and_return(entry_data)
    expect(client).to receive(:post).with("/blacklist/validate", validation_data).and_return([])
    expect(client).to receive(:delete).with("/blacklist/user%40example.com").and_return(nil)

    expect(resource.create(entry_data)).to eq(entry_data)
    expect(resource.update(entry_data)).to eq(entry_data)
    expect(resource.validate(validation_data)).to eq([])
    expect(resource.destroy("user@example.com")).to be_nil
  end
end
