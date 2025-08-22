#!/usr/bin/env ruby
# Test script to verify CleverReach OAuth credentials manually

require 'net/http'
require 'uri'
require 'json'

puts "CleverReach OAuth Token Test"
puts "=" * 40

# Get credentials from environment or prompt
client_id = ENV['CLEVERREACH_CLIENT_ID'] || begin
  print "Enter your Client ID: "
  gets.chomp
end

client_secret = ENV['CLEVERREACH_CLIENT_SECRET'] || begin
  print "Enter your Client Secret: "
  gets.chomp
end

if client_id.empty? || client_secret.empty?
  puts "❌ Client ID and Client Secret are required"
  exit 1
end

puts "\n🔑 Testing credentials..."
puts "Client ID: #{client_id[0..8]}..."
puts "Base URL: https://rest.cleverreach.com/oauth/token.php"

# Manual HTTP request to test OAuth
uri = URI('https://rest.cleverreach.com/oauth/token.php')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request['Content-Type'] = 'application/x-www-form-urlencoded'
request['User-Agent'] = 'CleverReach Ruby Gem Test'
request.set_form_data({
  'grant_type' => 'client_credentials',
  'client_id' => client_id,
  'client_secret' => client_secret
})

puts "\n📤 Sending OAuth request..."

begin
  response = http.request(request)
  
  puts "\n📥 Response received:"
  puts "Status: #{response.code}"
  puts "Headers: #{response.to_hash}"
  puts "Body: #{response.body}"
  
  if response.code == '200'
    data = JSON.parse(response.body)
    if data['access_token']
      puts "\n✅ SUCCESS! OAuth token received"
      puts "Token: #{data['access_token'][0..20]}..."
      puts "Expires in: #{data['expires_in']} seconds"
      
      # Test API call with the token
      puts "\n🧪 Testing API call with token..."
      api_uri = URI('https://rest.cleverreach.com/v3/groups')
      api_http = Net::HTTP.new(api_uri.host, api_uri.port)
      api_http.use_ssl = true
      
      api_request = Net::HTTP::Get.new(api_uri)
      api_request['Authorization'] = "Bearer #{data['access_token']}"
  api_request['User-Agent'] = 'CleverReach Ruby Gem Test'
      
      api_response = api_http.request(api_request)
      puts "API Status: #{api_response.code}"
      puts "API Body: #{api_response.body[0..200]}#{api_response.body.length > 200 ? '...' : ''}"
      
      if api_response.code == '200'
        puts "✅ API call successful!"
      else
        puts "❌ API call failed - check your account permissions"
      end
    else
      puts "❌ No access token in response"
    end
  else
    puts "❌ OAuth failed with status #{response.code}"
    puts "This usually means:"
    puts "- Wrong Client ID or Client Secret"
    puts "- OAuth app not properly configured"
    puts "- Account doesn't have API access"
  end
  
rescue => e
  puts "❌ Error: #{e.message}"
  puts "Check your internet connection and API credentials"
end

puts "\n" + "=" * 40
puts "If OAuth works but API calls fail, check:"
puts "1. Your CleverReach account has v3 API access"
puts "2. Your OAuth app has the necessary scopes"
puts "3. Try different API base URLs (eu1, us1, etc.)"
