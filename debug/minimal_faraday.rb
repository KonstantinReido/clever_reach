#!/usr/bin/env ruby
# Minimal Faraday test to isolate the issue

require 'faraday'
require 'json'

# Token from our working auth
token = "***REMOVED***"

puts "🧪 Minimal Faraday Test"
puts "=" * 30

# Test 1: Absolute minimal Faraday config
puts "\n1️⃣  Testing minimal Faraday..."
conn1 = Faraday.new(url: 'https://rest.cleverreach.com/v3')
response1 = conn1.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
end
puts "Status: #{response1.status}"
puts "Body: #{response1.body[0..100]}#{response1.body.length > 100 ? '...' : ''}"

# Test 2: With JSON response middleware (like our gem)
puts "\n2️⃣  Testing with JSON response middleware..."
conn2 = Faraday.new(url: 'https://rest.cleverreach.com/v3') do |builder|
  builder.response :json, content_type: /\bjson$/
  builder.adapter Faraday.default_adapter
end
response2 = conn2.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = 'CleverReach Ruby Gem 0.1.0'
end
puts "Status: #{response2.status}"
puts "Body: #{response2.body}"

# Test 3: Check if the issue is with error handling
puts "\n3️⃣  Raw response analysis..."
if response2.status != 200
  puts "Error detected!"
  puts "Headers: #{response2.headers}"
  puts "Raw body: #{response2.body}"
  
  # Let's see what the raw HTTP response actually contains
  conn3 = Faraday.new(url: 'https://rest.cleverreach.com/v3')
  response3 = conn3.get('/groups') do |req|
    req.headers['Authorization'] = "Bearer #{token}"
  end
  puts "Raw response body: #{response3.body}"
end
