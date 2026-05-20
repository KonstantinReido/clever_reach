require "spec_helper"

RSpec.describe CleverReach::Resources::Attributes do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists attributes" do
    expect(client).to receive(:get).with("/attributes", { group_id: 123 }).and_return([])

    expect(resource.all(group_id: 123)).to eq([])
  end

  it "fetches attribute limits" do
    expect(client).to receive(:get).with("/attributes", {}).and_return([])
    expect(client).to receive(:get).with("/attributes/limits", {}).and_return({})

    expect(resource.all).to eq([])
    expect(resource.limits).to eq({})
  end

  it "finds, creates, updates, and deletes attributes" do
    attribute_data = { name: "firstname", type: "text" }

    expect(client).to receive(:get).with("/attributes/first%20name", {}).and_return(attribute_data)
    expect(client).to receive(:post).with("/attributes", attribute_data).and_return(attribute_data)
    expect(client).to receive(:put).with("/attributes/first%20name", attribute_data).and_return(attribute_data)
    expect(client).to receive(:delete).with("/attributes/first%20name").and_return(nil)

    expect(resource.find("first name")).to eq(attribute_data)
    expect(resource.create(attribute_data)).to eq(attribute_data)
    expect(resource.update("first name", attribute_data)).to eq(attribute_data)
    expect(resource.destroy("first name")).to be_nil
  end
end
