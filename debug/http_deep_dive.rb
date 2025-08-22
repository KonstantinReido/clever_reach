#!/usr/bin/env ruby
# Deep dive into request differences

require 'faraday'
require 'net/http'
require 'uri'

token = "***REMOVED***"

puts "🔬 Deep HTTP Analysis"
puts "=" * 25

# Let's try to force Faraday to behave more like Net::HTTP
puts "\n🧪 Testing different Faraday configurations..."

# Test 1: Force HTTP/1.1 (Faraday might be using HTTP/2)
puts "\n1️⃣  Faraday with Net::HTTP adapter (explicit):"
conn1 = Faraday.new(url: 'https://rest.cleverreach.com/v3') do |builder|
  builder.adapter :net_http
end
response1 = conn1.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = "Ruby"
end
puts "Status: #{response1.status}"

# Test 2: Try different connection options
puts "\n2️⃣  Faraday with connection close:"
conn2 = Faraday.new(url: 'https://rest.cleverreach.com/v3') do |builder|
  builder.adapter :net_http
end
response2 = conn2.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = "Ruby"
  req.headers['Connection'] = "close"
end
puts "Status: #{response2.status}"

# Test 3: Try to mimic Net::HTTP headers exactly
puts "\n3️⃣  Faraday mimicking Net::HTTP headers:"
conn3 = Faraday.new(url: 'https://rest.cleverreach.com/v3') do |builder|
  builder.adapter :net_http
end
response3 = conn3.get('/groups') do |req|
  req.headers['Authorization'] = "Bearer #{token}"
  req.headers['User-Agent'] = "Ruby"
  req.headers['Accept'] = "*/*"
  req.headers['Accept-Encoding'] = "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
end
puts "Status: #{response3.status}"

# Test 4: Check if it's about SSL/TLS version
puts "\n4️⃣  Let's check the exact Net::HTTP setup..."

# Inspect what Net::HTTP actually sends
uri = URI('https://rest.cleverreach.com/v3/groups')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true
http.set_debug_output($stdout) if ENV['DEBUG_HTTP']

request = Net::HTTP::Get.new(uri.path)
request['Authorization'] = "Bearer #{token}"

puts "Net::HTTP version: #{Net::HTTP::HTTPVersion}"
puts "Net::HTTP SSL options: verify_mode=#{http.verify_mode}, ca_file=#{http.ca_file}"

# Let's try to see if we can inspect the actual request
puts "\nMaking the working Net::HTTP request..."
response = http.request(request)
puts "Net::HTTP Status: #{response.code}"
puts "Net::HTTP Response headers: #{response.to_hash}"

puts "\n💡 Key insight: Something about Faraday's request format is being rejected"
puts "even when using the same adapter and headers. This suggests a low-level"
puts "protocol difference (HTTP version, SSL negotiation, etc.)"
