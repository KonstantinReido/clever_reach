require "spec_helper"

RSpec.describe CleverReach::Resources::Groups do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists groups" do
    expect(client).to receive(:get).with("/groups", {}).and_return([])

    expect(resource.all).to eq([])
  end

  it "finds a group" do
    expect(client).to receive(:get).with("/groups/123", {}).and_return({ "id" => 123 })

    expect(resource.find(123)).to eq({ "id" => 123 })
  end

  it "creates a group" do
    attributes = { name: "Newsletter" }

    expect(client).to receive(:post).with("/groups", attributes).and_return({ "name" => "Newsletter" })

    expect(resource.create(attributes)).to eq({ "name" => "Newsletter" })
  end

  it "updates a group" do
    attributes = { name: "Updated" }

    expect(client).to receive(:put).with("/groups/123", attributes).and_return({ "name" => "Updated" })

    expect(resource.update(123, attributes)).to eq({ "name" => "Updated" })
  end

  it "deletes a group" do
    expect(client).to receive(:delete).with("/groups/123").and_return(nil)

    expect(resource.destroy(123)).to be_nil
  end

  it "fetches group stats" do
    expect(client).to receive(:get).with("/groups/123/stats", {}).and_return({ "total_count" => 10 })

    expect(resource.stats(123)).to eq({ "total_count" => 10 })
  end

  it "manages group attributes" do
    attribute_data = { name: "firstname", type: "text" }

    expect(client).to receive(:get).with("/groups/123/attributes", {}).and_return([])
    expect(client).to receive(:post).with("/groups/123/attributes", attribute_data).and_return(attribute_data)
    expect(client).to receive(:put).with("/groups/123/attributes/456", attribute_data).and_return(attribute_data)
    expect(client).to receive(:delete).with("/groups/123/attributes/456").and_return(nil)

    expect(resource.attributes(123)).to eq([])
    expect(resource.create_attribute(123, attribute_data)).to eq(attribute_data)
    expect(resource.update_attribute(123, 456, attribute_data)).to eq(attribute_data)
    expect(resource.destroy_attribute(123, 456)).to be_nil
  end
end
