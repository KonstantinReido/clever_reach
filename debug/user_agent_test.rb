#!/usr/bin/env ruby
# Test User-Agent sensitivity

require 'faraday'
require 'net/http'
require 'uri'

token = "***REMOVED***"

puts "🕵️  User-Agent Investigation"
puts "=" * 35

# Test 1: Net::HTTP (we know this works)
puts "\n1️⃣  Net::HTTP (working approach):"
uri = URI('https://rest.cleverreach.com/v3/groups')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
request = Net::HTTP::Get.new(uri)
request['Authorization'] = "Bearer #{token}"
response = http.request(request)
puts "Status: #{response.code}"
puts "User-Agent sent: #{request['User-Agent'] || 'none'}"

# Test 2: Faraday with no User-Agent
puts "\n2️⃣  Faraday with no User-Agent:"
conn = Faraday.new(url: 'https://rest.cleverreach.com/v3')
response = conn.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
end
puts "Status: #{response.status}"

# Test 3: Faraday with Net::HTTP-like User-Agent
puts "\n3️⃣  Faraday with Ruby User-Agent:"
conn = Faraday.new(url: 'https://rest.cleverreach.com/v3')
response = conn.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = "Ruby"
end
puts "Status: #{response.status}"

# Test 4: Faraday with curl-like User-Agent
puts "\n4️⃣  Faraday with curl User-Agent:"
conn = Faraday.new(url: 'https://rest.cleverreach.com/v3')
response = conn.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = "curl/7.68.0"
end
puts "Status: #{response.status}"

# Test 5: Check what headers Net::HTTP actually sends
puts "\n5️⃣  Analyzing Net::HTTP headers..."
puts "Checking what headers Net::HTTP sends vs Faraday..."

# Let's capture the actual request
require 'webrick'
puts "Net::HTTP default User-Agent: #{Net::HTTP.new('example.com').send(:transport_request, Net::HTTP::Get.new('/'), nil)&.[]('User-Agent') rescue 'unknown'}"
