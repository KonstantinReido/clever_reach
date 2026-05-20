require "spec_helper"

RSpec.describe CleverReach::Resources::MyContent do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists, finds, creates, updates, and deletes content items" do
    data = { name: "Snippet" }

    expect(client).to receive(:get).with("/mycontent", {}).and_return([])
    expect(client).to receive(:get).with("/mycontent/123", {}).and_return(data)
    expect(client).to receive(:post).with("/mycontent", data).and_return(data)
    expect(client).to receive(:put).with("/mycontent/123", data).and_return(data)
    expect(client).to receive(:delete).with("/mycontent/123").and_return(nil)

    expect(resource.all).to eq([])
    expect(resource.find(123)).to eq(data)
    expect(resource.create(data)).to eq(data)
    expect(resource.update(123, data)).to eq(data)
    expect(resource.destroy(123)).to be_nil
  end
end
