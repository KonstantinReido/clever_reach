require "spec_helper"

RSpec.describe CleverReach::Resources::Recipients do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists recipients for a group" do
    expect(client).to receive(:get).with("/groups/123/receivers", { page: 2 }).and_return([])

    expect(resource.all(123, page: 2)).to eq([])
  end

  it "finds a recipient" do
    expect(client).to receive(:get).with("/groups/123/receivers/456", {}).and_return({ "id" => 456 })

    expect(resource.find(123, 456)).to eq({ "id" => 456 })
  end

  it "searches recipients" do
    expect(client).to receive(:get)
      .with("/groups/123/receivers/filter", { page: 2, query: "user@example.com" })
      .and_return([])

    expect(resource.search(123, "user@example.com", page: 2)).to eq([])
  end

  it "creates and batch creates recipients" do
    recipient_data = { email: "user@example.com" }
    batch_data = [recipient_data]

    expect(client).to receive(:post).with("/groups/123/receivers", recipient_data).and_return(recipient_data)
    expect(client).to receive(:post).with("/groups/123/receivers/insert", batch_data).and_return(batch_data)

    expect(resource.create(123, recipient_data)).to eq(recipient_data)
    expect(resource.batch_create(123, batch_data)).to eq(batch_data)
  end

  it "updates and deletes recipients" do
    recipient_data = { email: "updated@example.com" }

    expect(client).to receive(:put).with("/groups/123/receivers/456", recipient_data).and_return(recipient_data)
    expect(client).to receive(:delete).with("/groups/123/receivers/456").and_return(nil)

    expect(resource.update(123, 456, recipient_data)).to eq(recipient_data)
    expect(resource.destroy(123, 456)).to be_nil
  end

  it "updates subscription status" do
    expect(client).to receive(:post).with("/groups/123/receivers/456/unsubscribe", {}).and_return(nil)
    expect(client).to receive(:post).with("/groups/123/receivers/456/subscribe", {}).and_return(nil)
    expect(client).to receive(:put).with("/groups/123/receivers/456/setactive", {}).and_return(nil)
    expect(client).to receive(:put).with("/groups/123/receivers/456/setinactive", {}).and_return(nil)

    expect(resource.unsubscribe(123, 456)).to be_nil
    expect(resource.resubscribe(123, 456)).to be_nil
    expect(resource.activate(123, 456)).to be_nil
    expect(resource.deactivate(123, 456)).to be_nil
  end

  it "fetches events and triggers double opt-in" do
    options = { source: "signup" }

    expect(client).to receive(:get).with("/groups/123/receivers/456/events", { page: 2 }).and_return([])
    expect(client).to receive(:post).with("/groups/123/receivers/456/sendactivationmail", options).and_return(nil)

    expect(resource.events(123, 456, page: 2)).to eq([])
    expect(resource.trigger_double_opt_in(123, 456, options)).to be_nil
  end
end
