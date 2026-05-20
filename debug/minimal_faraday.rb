#!/usr/bin/env ruby
# Minimal Faraday test to isolate CleverReach request behavior.

require "faraday"

token = ENV.fetch("CLEVER_REACH_TOKEN")
api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", "https://rest.cleverreach.com/v3")

puts "Minimal Faraday test"
puts "=" * 30

conn1 = Faraday.new(url: api_base_url)
response1 = conn1.get("/groups") do |req|
  req.headers["Authorization"] = "Bearer #{token}"
end
puts "Minimal Faraday status: #{response1.status}"
puts "Minimal Faraday body bytes: #{response1.body.to_s.bytesize}"

conn2 = Faraday.new(url: api_base_url) do |builder|
  builder.response :json, content_type: /\bjson$/
  builder.adapter Faraday.default_adapter
end

response2 = conn2.get("/groups") do |req|
  req.headers["Authorization"] = "Bearer #{token}"
  req.headers["User-Agent"] = "CleverReach Ruby Gem Debug"
end
puts "Faraday JSON middleware status: #{response2.status}"
puts "Faraday JSON middleware body class: #{response2.body.class}"
