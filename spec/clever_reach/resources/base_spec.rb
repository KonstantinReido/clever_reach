require "spec_helper"

RSpec.describe CleverReach::Resources::Base do
  subject(:resource) { described_class.new(client) }

  let(:client) { instance_double(CleverReach::NetHttpClient) }

  describe "#resource_path" do
    it "joins and escapes path segments" do
      path = resource.send(:resource_path, "groups", "group 1/2", "receivers", "user@example.com")

      expect(path).to eq("/groups/group%201%2F2/receivers/user%40example.com")
    end

    it "raises for nil path segments" do
      expect { resource.send(:resource_path, "groups", nil) }
        .to raise_error(ArgumentError, "Path segments cannot be nil")
    end
  end
end
