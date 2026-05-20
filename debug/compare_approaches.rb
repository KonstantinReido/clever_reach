#!/usr/bin/env ruby
# Compare manual Net::HTTP authentication with the gem client.

require_relative "../lib/clever_reach"
require "json"
require "net/http"
require "uri"

client_id = ENV.fetch("CLEVER_REACH_CLIENT_ID")
client_secret = ENV.fetch("CLEVER_REACH_CLIENT_SECRET")
auth_url = ENV.fetch("CLEVER_REACH_AUTH_URL", "https://rest.cleverreach.com/oauth/token.php")
api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", "https://rest.cleverreach.com/v3")

def post_client_credentials(auth_url, client_id, client_secret)
  uri = URI(auth_url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"

  request = Net::HTTP::Post.new(uri)
  request["Content-Type"] = "application/x-www-form-urlencoded"
  request.set_form_data(
    "grant_type" => "client_credentials",
    "client_id" => client_id,
    "client_secret" => client_secret
  )

  http.request(request)
end

def get_groups(api_base_url, token, user_agent)
  uri = URI.join("#{api_base_url}/", "groups")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme == "https"

  request = Net::HTTP::Get.new(uri)
  request["Authorization"] = "Bearer #{token}"
  request["User-Agent"] = user_agent

  http.request(request)
end

puts "Comparing manual and gem authentication"
puts "=" * 45

manual_auth_response = post_client_credentials(auth_url, client_id, client_secret)
puts "Manual auth status: #{manual_auth_response.code}"

manual_token = JSON.parse(manual_auth_response.body).fetch("access_token")
manual_api_response = get_groups(api_base_url, manual_token, "CleverReach Ruby Debug")
puts "Manual groups status: #{manual_api_response.code}"

CleverReach.configure do |config|
  config.client_id = client_id
  config.client_secret = client_secret
  config.api_base_url = api_base_url
  config.auth_url = auth_url
end

client = CleverReach::Client.new
gem_token = client.auth.token
puts "Gem auth succeeded: #{!gem_token.to_s.empty?}"
puts "Manual and gem token match: #{manual_token == gem_token}"

groups = client.groups.all
puts "Gem groups result class: #{groups.class}"
puts "Gem groups count: #{groups.respond_to?(:size) ? groups.size : "unknown"}"
