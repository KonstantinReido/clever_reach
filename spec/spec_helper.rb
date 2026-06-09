require "clever_reach"
require "webmock/rspec"

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
