require "spec_helper"

RSpec.describe "direct file loading" do
  it "loads the HTTP helper directly" do
    expect { load File.expand_path("../../lib/clever_reach/http.rb", __dir__) }.not_to raise_error
  end

  it "loads resource classes directly" do
    expect { load File.expand_path("../../lib/clever_reach/resources/groups.rb", __dir__) }.not_to raise_error
    expect { load File.expand_path("../../lib/clever_reach/resources/recipients.rb", __dir__) }.not_to raise_error
  end

  it "loads the Net::HTTP client directly" do
    expect { load File.expand_path("../../lib/clever_reach/net_http_client.rb", __dir__) }.not_to raise_error
  end
end
