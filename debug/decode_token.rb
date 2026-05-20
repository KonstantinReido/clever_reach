#!/usr/bin/env ruby
# Decode a JWT supplied via CLEVER_REACH_TOKEN without printing the raw token.

require "base64"
require "json"

token = ENV.fetch("CLEVER_REACH_TOKEN")

def decode_part(part)
  Base64.urlsafe_decode64(part + ("=" * ((4 - part.length % 4) % 4)))
end

def redact_claims(value)
  case value
  when Hash
    value.each_with_object({}) do |(key, item), redacted|
      redacted[key] = key.to_s.match?(/token|secret|password|credential|key/i) ? "[REDACTED]" : redact_claims(item)
    end
  when Array
    value.map { |item| redact_claims(item) }
  else
    value
  end
end

header, payload, = token.split(".")
raise "CLEVER_REACH_TOKEN does not look like a JWT" unless header && payload

header_decoded = JSON.parse(decode_part(header))
payload_decoded = JSON.parse(decode_part(payload))

puts "JWT header:"
puts JSON.pretty_generate(redact_claims(header_decoded))

puts
puts "JWT payload:"
puts JSON.pretty_generate(redact_claims(payload_decoded))

puts
puts "Summary:"
puts "- Shard: #{payload_decoded["shard"]}" if payload_decoded.key?("shard")
puts "- Zone: #{payload_decoded["zone"]}" if payload_decoded.key?("zone")
puts "- Scopes: #{payload_decoded["scopes"]}" if payload_decoded.key?("scopes")
puts "- Issuer: #{payload_decoded["iss"]}" if payload_decoded.key?("iss")
