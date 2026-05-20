require "spec_helper"

RSpec.describe CleverReach::Resources::Forms do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists, finds, fetches code, and deletes forms" do
    expect(client).to receive(:get).with("/forms", {}).and_return([])
    expect(client).to receive(:get).with("/forms/123", {}).and_return({ "id" => 123 })
    expect(client).to receive(:get).with("/forms/123/code", { embedded: 1 }).and_return("<form></form>")
    expect(client).to receive(:delete).with("/forms/123").and_return(nil)

    expect(resource.all).to eq([])
    expect(resource.find(123)).to eq({ "id" => 123 })
    expect(resource.code(123, embedded: 1)).to eq("<form></form>")
    expect(resource.destroy(123)).to be_nil
  end

  it "sends form mails and creates forms from templates" do
    data = { email: "user@example.com" }

    expect(client).to receive(:post).with("/forms/123/send/subscribe", data).and_return({})
    expect(client).to receive(:post).with("/forms/456/createfromtemplate/subscribe", data).and_return({})

    expect(resource.send(123, "subscribe", data)).to eq({})
    expect(resource.create_from_template(456, "subscribe", data)).to eq({})
  end
end
