require "spec_helper"

RSpec.describe "resource HTTP requests" do
  let(:client) { CleverReach::NetHttpClient.new }

  before do
    allow(client.auth).to receive(:token).and_return("test_token")
  end

  it "sends GET requests with query params through resource methods" do
    stub_request(:get, "https://rest.cleverreach.com/v3/groups?order=name")
      .with(headers: { "Authorization" => "Bearer test_token" })
      .to_return(status: 200, body: [].to_json)

    expect(client.groups.all(order: "name")).to eq([])
  end

  it "sends POST requests with JSON bodies through resource methods" do
    stub_request(:post, "https://rest.cleverreach.com/v3/groups")
      .with(
        body: { name: "Newsletter" }.to_json,
        headers: {
          "Authorization" => "Bearer test_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(status: 201, body: { id: 123, name: "Newsletter" }.to_json)

    expect(client.groups.create(name: "Newsletter"))
      .to eq({ "id" => 123, "name" => "Newsletter" })
  end

  it "sends PUT requests with JSON bodies through resource methods" do
    stub_request(:put, "https://rest.cleverreach.com/v3/groups/123")
      .with(
        body: { name: "Updated" }.to_json,
        headers: {
          "Authorization" => "Bearer test_token",
          "Content-Type" => "application/json"
        }
      )
      .to_return(status: 200, body: { id: 123, name: "Updated" }.to_json)

    expect(client.groups.update(123, name: "Updated"))
      .to eq({ "id" => 123, "name" => "Updated" })
  end

  it "sends DELETE requests with query params through resource methods" do
    stub_request(:delete, "https://rest.cleverreach.com/v3/receivers/456?group_id=123")
      .with(headers: { "Authorization" => "Bearer test_token" })
      .to_return(status: 204, body: "")

    expect(client.recipients.destroy_global(456, group_id: 123)).to be_nil
  end

  it "escapes path IDs before sending resource requests" do
    stub_request(:get, "https://rest.cleverreach.com/v3/groups/group%201/receivers/user%40example.com%2Fprimary")
      .with(headers: { "Authorization" => "Bearer test_token" })
      .to_return(status: 200, body: { email: "user@example.com" }.to_json)

    expect(client.recipients.find("group 1", "user@example.com/primary"))
      .to eq({ "email" => "user@example.com" })
  end
end
