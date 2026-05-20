require "spec_helper"

RSpec.describe CleverReach::Resources::Bounces do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists bounces" do
    expect(client).to receive(:get).with("/bounces", { page: 2, pagesize: 50 }).and_return([])

    expect(resource.all(page: 2, pagesize: 50)).to eq([])
  end
end
