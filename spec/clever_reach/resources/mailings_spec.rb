require "spec_helper"

RSpec.describe CleverReach::Resources::Mailings do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists, finds, creates, and updates mailings" do
    data = { name: "Campaign" }

    expect(client).to receive(:get).with("/mailings", { state: "draft" }).and_return([])
    expect(client).to receive(:get).with("/mailings/123", {}).and_return(data)
    expect(client).to receive(:post).with("/mailings", data).and_return(data)
    expect(client).to receive(:put).with("/mailings/123", data).and_return(data)

    expect(resource.all(state: "draft")).to eq([])
    expect(resource.find(123)).to eq(data)
    expect(resource.create(data)).to eq(data)
    expect(resource.update(123, data)).to eq(data)
  end

  it "wraps mailing channel and template endpoints" do
    data = { name: "Template" }

    expect(client).to receive(:get).with("/mailings/channel", {}).and_return([])
    expect(client).to receive(:get).with("/mailings/channel/123", {}).and_return({})
    expect(client).to receive(:delete).with("/mailings/channel/123").and_return(nil)
    expect(client).to receive(:post).with("/mailings/template", data).and_return(data)
    expect(client).to receive(:get).with("/mailings/templates/agency", {}).and_return([])
    expect(client).to receive(:get).with("/mailings/templates/user", {}).and_return([])

    expect(resource.channels).to eq([])
    expect(resource.channel(123)).to eq({})
    expect(resource.destroy_channel(123)).to be_nil
    expect(resource.create_template(data)).to eq(data)
    expect(resource.agency_templates).to eq([])
    expect(resource.user_templates).to eq([])
  end

  it "wraps mailing detail actions" do
    preview_data = { email: "user@example.com" }

    expect(client).to receive(:get).with("/mailings/123/links", {}).and_return([])
    expect(client).to receive(:get).with("/mailings/123/orders", {}).and_return([])
    expect(client).to receive(:get).with("/mailings/123/randomreceiver", {}).and_return({})
    expect(client).to receive(:post).with("/mailings/123/sendpreview", preview_data).and_return({})

    expect(resource.links(123)).to eq([])
    expect(resource.orders(123)).to eq([])
    expect(resource.random_receiver(123)).to eq({})
    expect(resource.send_preview(123, preview_data)).to eq({})
  end
end
