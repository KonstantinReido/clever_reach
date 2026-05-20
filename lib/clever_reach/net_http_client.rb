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
      
      add_query_params(uri, data) if method == :get && !data.empty?

      http = build_http(uri)
      request = build_request(method, uri, data)

      request['Authorization'] = "Bearer #{auth.token}"
      request['User-Agent'] = @configuration.user_agent

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

    def add_query_params(uri, params)
      query_params = URI.decode_www_form(uri.query.to_s)
      query_params.concat(params.map { |key, value| [key, value] })
      uri.query = URI.encode_www_form(query_params)
    end

    def build_http(uri)
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = @configuration.open_timeout
        http.read_timeout = @configuration.timeout
      end
    end

    def build_request(method, uri, data)
      case method
      when :get
        Net::HTTP::Get.new(uri.request_uri)
      when :post
        json_request(Net::HTTP::Post.new(uri.request_uri), data)
      when :put
        json_request(Net::HTTP::Put.new(uri.request_uri), data)
      when :delete
        Net::HTTP::Delete.new(uri.request_uri)
      else
        raise APIError, "Unsupported HTTP method: #{method}"
      end
    end

    def json_request(request, data)
      request.body = data.to_json
      request['Content-Type'] = 'application/json'
      request
    end

    def handle_response(response)
      case response.code.to_i
      when 200..299
        JSON.parse(response.body) unless blank?(response.body)
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
      ErrorParser.message(response.body, "HTTP #{response.code}")
    end

    def blank?(value)
      value.to_s.strip.empty?
    end
  end
end
