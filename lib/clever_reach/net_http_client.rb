require "net/http"
require "json"
require_relative "auth"
require_relative "configuration"
require_relative "errors"
require_relative "error_parser"
require_relative "http"
require_relative "resources/attributes"
require_relative "resources/blacklist"
require_relative "resources/bounces"
require_relative "resources/clients"
require_relative "resources/debug"
require_relative "resources/forms"
require_relative "resources/groups"
require_relative "resources/mailings"
require_relative "resources/my_content"
require_relative "resources/oauth"
require_relative "resources/recipients"
require_relative "resources/reports"

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

    def attributes
      @attributes ||= Resources::Attributes.new(self)
    end

    def blacklist
      @blacklist ||= Resources::Blacklist.new(self)
    end

    def bounces
      @bounces ||= Resources::Bounces.new(self)
    end

    def clients
      @clients ||= Resources::Clients.new(self)
    end

    def debug
      @debug ||= Resources::Debug.new(self)
    end

    def forms
      @forms ||= Resources::Forms.new(self)
    end

    def mailings
      @mailings ||= Resources::Mailings.new(self)
    end

    def my_content
      @my_content ||= Resources::MyContent.new(self)
    end

    def oauth
      @oauth ||= Resources::Oauth.new(self)
    end

    def recipients
      @recipients ||= Resources::Recipients.new(self)
    end

    def reports
      @reports ||= Resources::Reports.new(self)
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

    def delete(path, params = {})
      request(:delete, path, params)
    end

    private

    def request(method, path, data = {})
      uri = build_uri(path)
      
      add_query_params(uri, data) if [:get, :delete].include?(method) && !data.empty?

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
      HTTP.uri_for(@configuration.api_base_url, path, label: "API base URL")
    end

    def add_query_params(uri, params)
      query_params = URI.decode_www_form(uri.query.to_s)
      query_params.concat(params.map { |key, value| [key, value] })
      uri.query = URI.encode_www_form(query_params)
    end

    def build_http(uri)
      HTTP.connection(uri, @configuration)
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
