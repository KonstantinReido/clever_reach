#!/usr/bin/env ruby
# Test the gem client authentication with credentials from the environment.

require_relative "../lib/clever_reach"

CleverReach.configure do |config|
  config.client_id = ENV.fetch("CLEVER_REACH_CLIENT_ID")
  config.client_secret = ENV.fetch("CLEVER_REACH_CLIENT_SECRET")
  config.api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", config.api_base_url)
  config.auth_url = ENV.fetch("CLEVER_REACH_AUTH_URL", config.auth_url)
  config.user_agent = ENV.fetch("CLEVER_REACH_DEBUG_USER_AGENT", config.user_agent)
end

puts "Testing CleverReach authentication"
puts "=" * 40

client = CleverReach::NetHttpClient.new
token = client.auth.token
puts "Authentication successful: #{!token.to_s.empty?}"

groups = client.groups.all
puts "Groups request succeeded: #{groups.is_a?(Array) || groups.is_a?(Hash)}"
puts "Groups count: #{groups.respond_to?(:size) ? groups.size : "unknown"}"
