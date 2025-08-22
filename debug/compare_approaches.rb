#!/usr/bin/env ruby
# Compare manual vs gem approach to identify the issue

require_relative '../lib/clever_reach'
require 'net/http'
require 'uri'
require 'json'

# Working credentials
client_id = "***REMOVED***"
client_secret = "***REMOVED***"

puts "🔍 Debugging CleverReach API Issue"
puts "=" * 50

# First, get a token manually (we know this works)
puts "\n1️⃣  Getting token manually..."
uri = URI('https://rest.cleverreach.com/oauth/token.php')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request.set_form_data({
  'grant_type' => 'client_credentials',
  'client_id' => client_id,
  'client_secret' => client_secret
})

response = http.request(request)
manual_token = JSON.parse(response.body)['access_token']
puts "✅ Manual token: #{manual_token[0..20]}..."

# Test manual API call (we know this works)
puts "\n2️⃣  Testing manual API call..."
api_uri = URI('https://rest.cleverreach.com/v3/groups')
api_http = Net::HTTP.new(api_uri.host, api_uri.port)
api_http.use_ssl = true

api_request = Net::HTTP::Get.new(api_uri)
api_request['Authorization'] = "Bearer #{manual_token}"
api_request['User-Agent'] = 'Manual Test'

manual_api_response = api_http.request(api_request)
puts "✅ Manual API call: Status #{manual_api_response.code}"

# Now test with the gem
puts "\n3️⃣  Testing with gem..."
CleverReach.configure do |config|
  config.client_id = client_id
  config.client_secret = client_secret
end

client = CleverReach::Client.new
gem_token = client.auth.token
puts "✅ Gem token: #{gem_token[0..20]}..."

# Compare tokens
puts "\n4️⃣  Comparing tokens..."
puts "Tokens match: #{manual_token == gem_token}"

# Now let's check what the gem's Faraday connection looks like vs manual
puts "\n5️⃣  Testing gem API call with debugging..."
begin
  # Let's inspect the actual request the gem makes
  connection = client.connection
  puts "Gem connection URL: #{connection.url_prefix}"
  puts "Gem connection headers: #{connection.headers}"
  
  # Make the call
  groups = client.groups.all
  puts "✅ Gem API call successful"
rescue => e
  puts "❌ Gem API call failed: #{e.message}"
  
  # Let's try making the same call with manual approach using gem's token
  puts "\n6️⃣  Trying manual API call with gem's token..."
  manual_api_request2 = Net::HTTP::Get.new(api_uri)
  manual_api_request2['Authorization'] = "Bearer #{gem_token}"
  manual_api_request2['User-Agent'] = 'Manual Test with Gem Token'
  
  manual_response2 = api_http.request(manual_api_request2)
  puts "Manual with gem token: Status #{manual_response2.code}"
  puts "Response: #{manual_response2.body}"
end
