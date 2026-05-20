require "spec_helper"

RSpec.describe CleverReach::Resources::Oauth do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  it "revokes the current token" do
    expect(client).to receive(:delete).with("/oauth/token").and_return(nil)

    expect(resource.revoke_token).to be_nil
  end
end
