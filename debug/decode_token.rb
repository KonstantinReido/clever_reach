#!/usr/bin/env ruby
# Decode JWT to understand the token structure

require 'json'
require 'base64'

token = "***REMOVED***"

puts "🔍 JWT Token Analysis"
puts "=" * 30

# Split JWT parts
header, payload, signature = token.split('.')

# Decode header
puts "\n📝 Header:"
header_decoded = JSON.parse(Base64.decode64(header + '=='))
puts JSON.pretty_generate(header_decoded)

# Decode payload  
puts "\n📝 Payload:"
payload_decoded = JSON.parse(Base64.decode64(payload + '=='))
puts JSON.pretty_generate(payload_decoded)

puts "\n🔍 Key observations:"
puts "- Shard: #{payload_decoded['shard']}"
puts "- Zone: #{payload_decoded['zone']}"
puts "- Scopes: #{payload_decoded['scopes']}"
puts "- Issuer: #{payload_decoded['iss']}"

puts "\n💡 The token indicates:"
puts "- Your account is on shard16, zone 4"
puts "- The issuer is 'rest.cleverreach.com' (not shard-specific)"
puts "- You have all necessary OAuth scopes"

puts "\n🤔 Possible issue:"
puts "The error 'v3 token on lower version' might mean the API expects"
puts "requests to be made to the correct shard endpoint, even though"
puts "the manual approach with the main endpoint works."

puts "\nLet's try different API base URLs..."
