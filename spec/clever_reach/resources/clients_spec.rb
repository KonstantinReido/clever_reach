require "spec_helper"

RSpec.describe CleverReach::Resources::Clients do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "lists, finds, and finds clients by domain" do
    expect(client).to receive(:get).with("/clients", { page: 2 }).and_return([])
    expect(client).to receive(:get).with("/clients/123", {}).and_return({ "id" => 123 })
    expect(client).to receive(:get).with("/clients/domain/example.com", {}).and_return({ "domain" => "example.com" })

    expect(resource.all(page: 2)).to eq([])
    expect(resource.find(123)).to eq({ "id" => 123 })
    expect(resource.find_by_domain("example.com")).to eq({ "domain" => "example.com" })
  end

  it "fetches client details" do
    expect(client).to receive(:get).with("/clients/123/activereceivercount", {}).and_return(1)
    expect(client).to receive(:get).with("/clients/123/contingent", {}).and_return({})
    expect(client).to receive(:get).with("/clients/123/invoiceaddress", {}).and_return({})
    expect(client).to receive(:get).with("/clients/123/limits", {}).and_return({})
    expect(client).to receive(:get).with("/clients/123/nextinvoicedate", {}).and_return("2026-05-20")
    expect(client).to receive(:get).with("/clients/123/plan", {}).and_return({})
    expect(client).to receive(:get).with("/clients/123/receivercount", {}).and_return(2)
    expect(client).to receive(:get).with("/clients/123/users", {}).and_return([])

    expect(resource.active_receiver_count(123)).to eq(1)
    expect(resource.contingent(123)).to eq({})
    expect(resource.invoice_address(123)).to eq({})
    expect(resource.limits(123)).to eq({})
    expect(resource.next_invoice_date(123)).to eq("2026-05-20")
    expect(resource.plan(123)).to eq({})
    expect(resource.receiver_count(123)).to eq(2)
    expect(resource.users(123)).to eq([])
  end

  it "updates client payment settings" do
    data = { type: "invoice" }

    expect(client).to receive(:put).with("/clients/123/paymentoptions", data).and_return(data)
    expect(client).to receive(:put).with("/clients/123/paymentsource", data).and_return(data)

    expect(resource.update_payment_options(123, data)).to eq(data)
    expect(resource.update_payment_source(123, data)).to eq(data)
  end
end
