require "spec_helper"

RSpec.describe CleverReach::Resources::Groups do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists groups" do
    expect(client).to receive(:get).with("/groups", { order: "name" }).and_return([])

    expect(resource.all(order: "name")).to eq([])
  end

  it "finds a group" do
    expect(client).to receive(:get).with("/groups/123", {}).and_return({ "id" => 123 })

    expect(resource.find(123)).to eq({ "id" => 123 })
  end

  it "escapes path IDs" do
    expect(client).to receive(:get).with("/groups/group%201%2F2", {}).and_return({ "id" => "group 1/2" })

    expect(resource.find("group 1/2")).to eq({ "id" => "group 1/2" })
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
    expect(client).to receive(:get).with("/groups/123/advancedstats", {}).and_return({ "active_count" => 5 })

    expect(resource.stats(123)).to eq({ "total_count" => 10 })
    expect(resource.advanced_stats(123)).to eq({ "active_count" => 5 })
  end

  it "manages group blacklist entries" do
    data = { email: "user@example.com" }

    expect(client).to receive(:get).with("/groups/123/blacklist", {}).and_return([])
    expect(client).to receive(:post).with("/groups/123/blacklist", data).and_return(data)
    expect(client).to receive(:delete).with("/groups/123/blacklist/user%40example.com").and_return(nil)

    expect(resource.blacklist(123)).to eq([])
    expect(resource.add_to_blacklist(123, data)).to eq(data)
    expect(resource.remove_from_blacklist(123, "user@example.com")).to be_nil
  end

  it "clears a group and fetches group forms" do
    expect(client).to receive(:delete).with("/groups/123/clear").and_return(nil)
    expect(client).to receive(:get).with("/groups/123/forms", {}).and_return([])

    expect(resource.clear(123)).to be_nil
    expect(resource.forms(123)).to eq([])
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

  it "manages group filters" do
    filter_data = { name: "Active customers" }

    expect(client).to receive(:get).with("/groups/123/filters", {}).and_return([])
    expect(client).to receive(:post).with("/groups/123/filters", filter_data).and_return(filter_data)
    expect(client).to receive(:get).with("/groups/123/filters/456", {}).and_return(filter_data)
    expect(client).to receive(:put).with("/groups/123/filters/456", filter_data).and_return(filter_data)
    expect(client).to receive(:delete).with("/groups/123/filters/456").and_return(nil)
    expect(client).to receive(:get).with("/groups/123/filters/456/count", {}).and_return(10)
    expect(client).to receive(:get).with("/groups/123/filters/456/receivers", { page: 2 }).and_return([])
    expect(client).to receive(:get).with("/groups/123/filters/456/stats", {}).and_return({})

    expect(resource.filters(123)).to eq([])
    expect(resource.create_filter(123, filter_data)).to eq(filter_data)
    expect(resource.find_filter(123, 456)).to eq(filter_data)
    expect(resource.update_filter(123, 456, filter_data)).to eq(filter_data)
    expect(resource.destroy_filter(123, 456)).to be_nil
    expect(resource.filter_count(123, 456)).to eq(10)
    expect(resource.filter_receivers(123, 456, page: 2)).to eq([])
    expect(resource.filter_stats(123, 456)).to eq({})
  end
end
