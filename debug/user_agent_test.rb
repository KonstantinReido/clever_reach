#!/usr/bin/env ruby
# Test whether CleverReach responses vary by User-Agent.

require "faraday"
require "net/http"
require "uri"

token = ENV.fetch("CLEVER_REACH_TOKEN")
api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", "https://rest.cleverreach.com/v3")

puts "User-Agent investigation"
puts "=" * 35

uri = URI.join("#{api_base_url}/", "groups")
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == "https"
request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{token}"
response = http.request(request)
puts "Net::HTTP default User-Agent status: #{response.code}"
puts "Net::HTTP User-Agent header: #{request["User-Agent"] || "none"}"

[
  ["Faraday without User-Agent", nil],
  ["Faraday with Ruby User-Agent", "Ruby"],
  ["Faraday with curl User-Agent", "curl/7.68.0"]
].each do |label, user_agent|
  conn = Faraday.new(url: api_base_url)
  faraday_response = conn.get("/groups") do |req|
    req.headers["Authorization"] = "Bearer #{token}"
    req.headers["User-Agent"] = user_agent if user_agent
  end
  puts "#{label}: #{faraday_response.status}"
end
