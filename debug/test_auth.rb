#!/usr/bin/env ruby

require_relative "../lib/clever_reach"

# Configure with your actual credentials
CleverReach.configure do |config|
  config.client_id = ENV["CLEVERREACH_CLIENT_ID"] || "***REMOVED***"  # Use working credentials
  config.client_secret = ENV["CLEVERREACH_CLIENT_SECRET"] || "***REMOVED***"
end

puts "Testing CleverReach Authentication..."
puts "API Base URL: #{CleverReach.configuration.api_base_url}"

begin
  # Initialize the client
client = CleverReach::NetHttpClient.new
  puts "✅ Client created successfully"
  
  puts "Testing authentication..."
  token = client.auth.token
  puts "✅ Authentication successful"
  puts "Token: #{token[0..20]}..." if token
  
  puts "\nTesting API call..."
  groups = client.groups.all
  puts "✅ API call successful"
  puts "Found #{groups.is_a?(Array) ? groups.size : 'unknown'} groups"
  
rescue CleverReach::AuthenticationError => e
  puts "❌ Authentication Error: #{e.message}"
rescue CleverReach::APIError => e
  puts "❌ API Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
  puts "Response Body: #{e.response_body}" if e.response_body
rescue CleverReach::ConfigurationError => e
  puts "❌ Configuration Error: #{e.message}"
  puts "Make sure to set CLEVERREACH_CLIENT_ID and CLEVERREACH_CLIENT_SECRET environment variables"
rescue StandardError => e
  puts "❌ Unexpected Error: #{e.class}: #{e.message}"
  puts e.backtrace.first(3)
end
