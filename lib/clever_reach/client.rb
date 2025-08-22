require "faraday"
require "json"

module CleverReach
  class Client
    attr_reader :configuration, :auth

    def initialize(configuration = nil)
  @configuration = configuration || CleverReach.configuration
      
      raise ConfigurationError, "Client ID is required" unless @configuration.client_id
      raise ConfigurationError, "Client Secret is required" unless @configuration.client_secret
      
      @auth = Auth.new(@configuration)
    end

    def groups
      @groups ||= Resources::Groups.new(self)
    end

    def recipients
      @recipients ||= Resources::Recipients.new(self)
    end

    def connection
      @connection ||= Faraday.new(
        url: @configuration.api_base_url,
        headers: default_headers
      ) do |builder|
        builder.response :json, content_type: /\bjson$/
        builder.adapter Faraday.default_adapter
      end
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, data = {})
      request(:post, path, data)
    end

    def put(path, data = {})
      request(:put, path, data)
    end

    def delete(path)
      request(:delete, path)
    end

    private

    def request(method, path, data = {})
      response = connection.send(method) do |req|
        req.url path
        req.headers["Authorization"] = "Bearer #{auth.token}"
        
        if [:post, :put].include?(method)
          req.headers["Content-Type"] = "application/json"
          req.body = data.to_json
        else
          req.params = data
        end
      end

      handle_response(response)
    rescue Faraday::Error => e
      handle_faraday_error(e)
    end

    def handle_response(response)
      case response.status
      when 200..299
        response.body
      when 400
        raise ValidationError, parse_error_message(response)
      when 401
        raise AuthenticationError, "Unauthorized: #{parse_error_message(response)}"
      when 404
        raise NotFoundError, "Resource not found: #{parse_error_message(response)}"
      when 429
        raise RateLimitError, "Rate limit exceeded: #{parse_error_message(response)}"
      else
        raise APIError.new(
          "API request failed: #{parse_error_message(response)}",
          response.status,
          response.body
        )
      end
    end

    def handle_faraday_error(error)
      case error
      when Faraday::TimeoutError
        raise APIError, "Request timeout"
      when Faraday::ConnectionFailed
        raise APIError, "Connection failed"
      else
        raise APIError, "Request failed: #{error.message}"
      end
    end

    def parse_error_message(response)
      if response.body.is_a?(Hash) && response.body["message"]
        response.body["message"]
      elsif response.body.is_a?(Hash) && response.body["error"]
        response.body["error"]
      else
        response.body.to_s
      end
    end

    def default_headers
      {
  "User-Agent" => "CleverReach Ruby Gem #{CleverReach::VERSION}"
      }
    end
  end
end
