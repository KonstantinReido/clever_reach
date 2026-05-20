require "spec_helper"

RSpec.describe CleverReach::Resources::Reports do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists, finds, and deletes reports" do
    expect(client).to receive(:get).with("/reports", { page: 2 }).and_return([])
    expect(client).to receive(:get).with("/reports/123", {}).and_return({ "id" => 123 })
    expect(client).to receive(:delete).with("/reports/123").and_return(nil)

    expect(resource.all(page: 2)).to eq([])
    expect(resource.find(123)).to eq({ "id" => 123 })
    expect(resource.destroy(123)).to be_nil
  end

  it "fetches report receivers and stats" do
    expect(client).to receive(:get).with("/reports/123/receivers/opened", { page: 2 }).and_return([])
    expect(client).to receive(:get).with("/reports/123/stats/daily", { start: "2026-01-01" }).and_return({})

    expect(resource.receivers(123, "opened", page: 2)).to eq([])
    expect(resource.stats(123, "daily", start: "2026-01-01")).to eq({})
  end
end
