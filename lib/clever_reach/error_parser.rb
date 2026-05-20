require "json"

module CleverReach
  module ErrorParser
    module_function

    def message(body, fallback = "")
      return fallback if body.to_s.strip.empty?

      data = JSON.parse(body)
      return data["message"] || data["error_description"] || data["error"] || body if data.is_a?(Hash)

      body
    rescue JSON::ParserError
      body
    end
  end
end
