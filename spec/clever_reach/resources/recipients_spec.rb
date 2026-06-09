require "spec_helper"

RSpec.describe CleverReach::Resources::Recipients do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists recipients for a group" do
    expect(client).to receive(:get).with("/groups/123/receivers", { page: 2 }).and_return([])

    expect(resource.all(123, page: 2)).to eq([])
  end

  it "lists recipients for a group with POST filters" do
    filter_data = { filter: "active" }

    expect(client).to receive(:post).with("/groups/123/get_receivers", filter_data).and_return([])

    expect(resource.list(123, filter_data)).to eq([])
  end

  it "finds a recipient" do
    expect(client).to receive(:get).with("/groups/123/receivers/456", {}).and_return({ "id" => 456 })

    expect(resource.find(123, 456)).to eq({ "id" => 456 })
  end

  it "escapes group and recipient path IDs" do
    expect(client).to receive(:get)
      .with("/groups/group%201/receivers/user%40example.com%2Fprimary", {})
      .and_return({ "email" => "user@example.com" })

    expect(resource.find("group 1", "user@example.com/primary")).to eq({ "email" => "user@example.com" })
  end

  it "creates a recipient" do
    recipient_data = { email: "user@example.com" }

    expect(client).to receive(:post).with("/groups/123/receivers", recipient_data).and_return(recipient_data)

    expect(resource.create(123, recipient_data)).to eq(recipient_data)
  end

  it "batch creates and deletes recipients" do
    batch_data = [{ email: "user@example.com" }]

    expect(client).to receive(:post).with("/groups/123/receivers/insert", batch_data).and_return(batch_data)
    expect(client).to receive(:post).with("/groups/123/receivers/delete", batch_data).and_return(nil)

    expect(resource.batch_create(123, batch_data)).to eq(batch_data)
    expect(resource.batch_destroy(123, batch_data)).to be_nil
  end

  it "batch updates recipients" do
    batch_data = [{ email: "user@example.com" }]

    expect(client).to receive(:put).with("/groups/123/receivers/update", batch_data).and_return(batch_data)
    expect(client).to receive(:put).with("/groups/123/receivers/updateplus", batch_data).and_return(batch_data)

    expect(resource.batch_update(123, batch_data)).to eq(batch_data)
    expect(resource.batch_update_plus(123, batch_data)).to eq(batch_data)
  end

  it "batch upserts recipients" do
    batch_data = [{ email: "user@example.com" }]

    expect(client).to receive(:post).with("/groups/123/receivers/upsert", batch_data).and_return(batch_data)
    expect(client).to receive(:post).with("/groups/123/receivers/upsertplus", batch_data).and_return(batch_data)

    expect(resource.batch_upsert(123, batch_data)).to eq(batch_data)
    expect(resource.batch_upsert_plus(123, batch_data)).to eq(batch_data)
  end

  it "updates and deletes recipients" do
    recipient_data = { email: "updated@example.com" }

    expect(client).to receive(:put).with("/groups/123/receivers/456", recipient_data).and_return(recipient_data)
    expect(client).to receive(:delete).with("/groups/123/receivers/456").and_return(nil)

    expect(resource.update(123, 456, recipient_data)).to eq(recipient_data)
    expect(resource.destroy(123, 456)).to be_nil
  end

  it "updates activation status" do
    expect(client).to receive(:put).with("/groups/123/receivers/456/activate", {}).and_return(nil)
    expect(client).to receive(:put).with("/groups/123/receivers/456/deactivate", {}).and_return(nil)

    expect(resource.activate(123, 456)).to be_nil
    expect(resource.deactivate(123, 456)).to be_nil
  end

  it "fetches and creates events" do
    options = { source: "signup" }

    expect(client).to receive(:get).with("/groups/123/receivers/456/events", { page: 2 }).and_return([])
    expect(client).to receive(:post).with("/groups/123/receivers/456/events", options).and_return(options)

    expect(resource.events(123, 456, page: 2)).to eq([])
    expect(resource.create_event(123, 456, options)).to eq(options)
  end

  it "updates attributes and manages orders within a group" do
    attribute_data = { value: "Jane" }
    order_data = { order_id: "A-1" }

    expect(client).to receive(:put).with("/groups/123/receivers/456/attributes/firstname", attribute_data).and_return(attribute_data)
    expect(client).to receive(:get).with("/groups/123/receivers/456/orders", {}).and_return([])
    expect(client).to receive(:post).with("/groups/123/receivers/456/orders", order_data).and_return(order_data)
    expect(client).to receive(:put).with("/groups/123/receivers/456/orders/A-1", order_data).and_return(order_data)
    expect(client).to receive(:delete).with("/groups/123/receivers/456/orders/A-1").and_return(nil)

    expect(resource.update_attribute(123, 456, "firstname", attribute_data)).to eq(attribute_data)
    expect(resource.orders(123, 456)).to eq([])
    expect(resource.create_order(123, 456, order_data)).to eq(order_data)
    expect(resource.update_order(123, 456, "A-1", order_data)).to eq(order_data)
    expect(resource.destroy_order(123, 456, "A-1")).to be_nil
  end

  it "finds, deletes, and fetches global receiver attributes" do
    recipient_data = { email: "user@example.com" }

    expect(client).to receive(:get).with("/receivers/user%40example.com", { group_id: 123 }).and_return(recipient_data)
    expect(client).to receive(:delete).with("/receivers/456", { group_id: 123 }).and_return(nil)
    expect(client).to receive(:get).with("/receivers/456/attributes", { group_id: 123 }).and_return([])

    expect(resource.find_global("user@example.com", group_id: 123)).to eq(recipient_data)
    expect(resource.destroy_global(456, group_id: 123)).to be_nil
    expect(resource.attributes(456, group_id: 123)).to eq([])
  end

  it "updates and clones global receiver identity data" do
    expect(client).to receive(:put).with("/receivers/456/attributes/firstname", { value: "Jane" }).and_return({})
    expect(client).to receive(:post).with("/receivers/456/clone", { email: "new@example.com" }).and_return({})
    expect(client).to receive(:put).with("/receivers/456/email", { email: "new@example.com" }).and_return({})

    expect(resource.update_global_attribute(456, "firstname", value: "Jane")).to eq({})
    expect(resource.clone(456, email: "new@example.com")).to eq({})
    expect(resource.change_email(456, email: "new@example.com")).to eq({})
  end

  it "fetches global receiver groups and orders" do
    expect(client).to receive(:get).with("/receivers/456/groups", { state: "active" }).and_return([])
    expect(client).to receive(:get).with("/receivers/456/orders", { group_id: 123 }).and_return([])

    expect(resource.groups(456, state: "active")).to eq([])
    expect(resource.global_orders(456, group_id: 123)).to eq([])
  end

  it "wraps global receiver events" do
    data = { email: "user@example.com" }

    expect(client).to receive(:get).with("/receivers/456/events", { group_id: 123 }).and_return([])
    expect(client).to receive(:post).with("/receivers/456/events", data).and_return(data)

    expect(resource.global_events(456, group_id: 123)).to eq([])
    expect(resource.create_global_event(456, data)).to eq(data)
  end

  it "wraps global receiver order mutations" do
    data = { email: "user@example.com" }

    expect(client).to receive(:post).with("/receivers/456/orders", data).and_return(data)
    expect(client).to receive(:put).with("/receivers/456/orders/A-1", data).and_return(data)
    expect(client).to receive(:delete).with("/receivers/456/orders/A-1").and_return(nil)

    expect(resource.create_global_order(456, data)).to eq(data)
    expect(resource.update_global_order(456, "A-1", data)).to eq(data)
    expect(resource.destroy_global_order(456, "A-1")).to be_nil
  end

  it "wraps global receiver bounces, bulk delete, filtering, and validation" do
    data = { email: "user@example.com" }

    expect(client).to receive(:get).with("/receivers/bounced", { page: 2 }).and_return([])
    expect(client).to receive(:post).with("/receivers/delete", [data]).and_return(nil)
    expect(client).to receive(:post).with("/receivers/filter", data).and_return([])
    expect(client).to receive(:post).with("/receivers/isvalid", data).and_return(true)

    expect(resource.bounced(page: 2)).to eq([])
    expect(resource.destroy_multiple([data])).to be_nil
    expect(resource.filter(data)).to eq([])
    expect(resource.valid?(data)).to be true
  end
end
