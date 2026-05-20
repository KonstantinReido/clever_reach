#!/usr/bin/env ruby
# Compare request behavior across Faraday and Net::HTTP using an env token.

require "faraday"
require "net/http"
require "uri"

token = ENV.fetch("CLEVER_REACH_TOKEN")
api_base_url = ENV.fetch("CLEVER_REACH_API_BASE_URL", "https://rest.cleverreach.com/v3")
groups_path = "/groups"

def faraday_groups(api_base_url, token, headers = {})
  conn = Faraday.new(url: api_base_url) do |builder|
    builder.adapter :net_http
  end

  conn.get("/groups") do |req|
    req.headers["Authorization"] = "Bearer #{token}"
    headers.each { |key, value| req.headers[key] = value }
  end
end

puts "Deep HTTP analysis"
puts "=" * 25

[
  ["Faraday with Net::HTTP adapter", {}],
  ["Faraday with connection close", { "Connection" => "close" }],
  [
    "Faraday mimicking Net::HTTP headers",
    {
      "User-Agent" => "Ruby",
      "Accept" => "*/*",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    }
  ]
].each do |label, headers|
  response = faraday_groups(api_base_url, token, headers)
  puts "#{label}: #{response.status}"
end

uri = URI.join("#{api_base_url}/", groups_path.sub(%r{\A/}, ""))
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == "https"

request = Net::HTTP::Get.new(uri)
request["Authorization"] = "Bearer #{token}"

response = http.request(request)
puts "Net::HTTP status: #{response.code}"
puts "Net::HTTP response header keys: #{response.to_hash.keys.sort.join(", ")}"
