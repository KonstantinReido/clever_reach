#!/usr/bin/env ruby
# Test CleverReach OAuth credentials manually with Net::HTTP.

require "json"
require "net/http"
require "uri"

client_id = ENV.fetch("CLEVER_REACH_CLIENT_ID")
client_secret = ENV.fetch("CLEVER_REACH_CLIENT_SECRET")
auth_url = ENV.fetch("CLEVER_REACH_AUTH_URL", "https://rest.cleverreach.com/oauth/token.php")
api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", "https://rest.cleverreach.com/v3")

puts "CleverReach manual OAuth test"
puts "=" * 40

auth_uri = URI(auth_url)
http = Net::HTTP.new(auth_uri.host, auth_uri.port)
http.use_ssl = auth_uri.scheme == "https"

request = Net::HTTP::Post.new(auth_uri)
request["Content-Type"] = "application/x-www-form-urlencoded"
request["User-Agent"] = "CleverReach Ruby Gem Debug"
request.set_form_data(
  "grant_type" => "client_credentials",
  "client_id" => client_id,
  "client_secret" => client_secret
)

auth_response = http.request(request)
puts "OAuth status: #{auth_response.code}"

unless auth_response.code == "200"
  puts "OAuth failed. Check the credentials and OAuth app configuration."
  exit 1
end

data = JSON.parse(auth_response.body)
token = data.fetch("access_token")
puts "OAuth token received: #{!token.empty?}"
puts "Expires in: #{data["expires_in"]} seconds" if data["expires_in"]

api_uri = URI.join("#{api_base_url}/", "groups")
api_http = Net::HTTP.new(api_uri.host, api_uri.port)
api_http.use_ssl = api_uri.scheme == "https"

api_request = Net::HTTP::Get.new(api_uri)
api_request["Authorization"] = "Bearer #{token}"
api_request["User-Agent"] = "CleverReach Ruby Gem Debug"

api_response = api_http.request(api_request)
puts "Groups API status: #{api_response.code}"
puts "Groups API returned bytes: #{api_response.body.to_s.bytesize}"
