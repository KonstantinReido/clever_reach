require "clever_reach"
require "webmock/rspec"
require "vcr"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
  CleverReach.reset_configuration!
  CleverReach.configure do |c|
      c.client_id = "test_client_id"
      c.client_secret = "test_client_secret"
    end
  end
end

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
end
