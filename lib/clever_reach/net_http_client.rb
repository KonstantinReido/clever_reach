require "net/http"
require "uri"
require "json"

module CleverReach
  class NetHttpClient
    attr_reader :configuration, :auth

    def initialize(configuration = nil)
      @configuration = configuration || CleverReach.configuration
      
      raise ConfigurationError, "Client ID is required" if blank?(@configuration.client_id)
      raise ConfigurationError, "Client Secret is required" if blank?(@configuration.client_secret)
      
      @auth = Auth.new(@configuration)
    end

    def groups
      @groups ||= Resources::Groups.new(self)
    end

    def recipients
      @recipients ||= Resources::Recipients.new(self)
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
      uri = build_uri(path)
      
      # Add query parameters for GET requests
      if method == :get && !data.empty?
        uri.query = URI.encode_www_form(data)
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @configuration.open_timeout
      http.read_timeout = @configuration.timeout

      request = case method
      when :get
        Net::HTTP::Get.new(uri.request_uri)
      when :post
        req = Net::HTTP::Post.new(uri.request_uri)
        req.body = data.to_json
        req['Content-Type'] = 'application/json'
        req
      when :put
        req = Net::HTTP::Put.new(uri.request_uri)
        req.body = data.to_json
        req['Content-Type'] = 'application/json'
        req
      when :delete
        Net::HTTP::Delete.new(uri.request_uri)
      end

      request['Authorization'] = "Bearer #{auth.token}"
      request['User-Agent'] = "CleverReach Ruby Gem #{CleverReach::VERSION}"

      response = http.request(request)
      handle_response(response)
    rescue CleverReach::Error
      raise
    rescue JSON::ParserError => e
      raise APIError, "Failed to parse response: #{e.message}"
    rescue IOError, SystemCallError, Timeout::Error, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
      raise APIError, "Request failed: #{e.message}"
    end

    def build_uri(path)
      base_url = @configuration.api_base_url.to_s.sub(%r{/+\z}, "")
      normalized_path = path.to_s.sub(%r{\A/+}, "")
      uri = URI("#{base_url}/#{normalized_path}")
      return uri if uri.is_a?(URI::HTTP) && uri.host

      raise ConfigurationError, "API base URL must be an absolute HTTP or HTTPS URL"
    rescue URI::InvalidURIError => e
      raise ConfigurationError, "API base URL is invalid: #{e.message}"
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body) if response.body && !response.body.empty?
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
          response.code.to_i,
          response.body
        )
      end
    end

    def parse_error_message(response)
      if response.body && !response.body.empty?
        data = JSON.parse(response.body)
        if data.is_a?(Hash)
          data["message"] || data["error"] || response.body
        else
          response.body
        end
      else
        "HTTP #{response.code}"
      end
    rescue JSON::ParserError
      response.body
    end

    def blank?(value)
      value.to_s.strip.empty?
    end
  end
end
