require "spec_helper"

RSpec.describe CleverReach::Resources::Debug do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "wraps debug endpoints" do
    expect(client).to receive(:get).with("/debug/exchange", {}).and_return({})
    expect(client).to receive(:get).with("/debug/ttl", {}).and_return(3600)
    expect(client).to receive(:get).with("/debug/validate", {}).and_return(true)
    expect(client).to receive(:get).with("/debug/whoami", {}).and_return({})

    expect(resource.exchange).to eq({})
    expect(resource.ttl).to eq(3600)
    expect(resource.validate).to be true
    expect(resource.whoami).to eq({})
  end
end
