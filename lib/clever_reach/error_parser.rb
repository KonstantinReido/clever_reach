require "json"

module CleverReach
  module ErrorParser
    module_function

    MAX_MESSAGE_LENGTH = 500
    SECRET_PATTERNS = [
      /((?:access_token|refresh_token|client_secret|password|api_key|secret)["']?\s*[:=]\s*["']?)[^"'\s&,}]+/i,
      /(Bearer\s+)[A-Za-z0-9._~+\/=-]+/i
    ].freeze

    def message(body, fallback = "")
      return fallback if body.to_s.strip.empty?

      data = JSON.parse(body)
      return sanitize(data["message"] || data["error_description"] || data["error"] || body) if data.is_a?(Hash)

      sanitize(body)
    rescue JSON::ParserError
      sanitize(body)
    end

    def sanitize(value)
      message = value.to_s.dup
      SECRET_PATTERNS.each do |pattern|
        message.gsub!(pattern, "\\1[REDACTED]")
      end

      return message if message.length <= MAX_MESSAGE_LENGTH

      "#{message[0, MAX_MESSAGE_LENGTH]}..."
    end
  end
end
