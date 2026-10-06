require "net/http"
require "json"
require "openssl"
require_relative "errors"
require_relative "error_parser"
require_relative "http"

module CleverReach
  class Auth
    MAX_SERVER_RETRIES = 2
    RETRY_BASE_DELAY = 0.1
    MAX_RETRY_DELAY = 0.5

    attr_reader :access_token, :expires_at

    def initialize(configuration)
      @configuration = configuration
      @access_token = nil
      @expires_at = nil
    end

    def authenticate!
      uri = auth_uri
      http = HTTP.connection(uri, @configuration)

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request['User-Agent'] = @configuration.user_agent
      request.set_form_data({
        'grant_type' => 'client_credentials',
        'client_id' => @configuration.client_id,
        'client_secret' => @configuration.client_secret
      })

      retries = 0
      loop do
        response = http.request(request)
        begin
          handle_auth_response(response)
          return
        rescue TransientAuthenticationError
          raise if retries >= MAX_SERVER_RETRIES

          sleep([RETRY_BASE_DELAY * (2**retries), MAX_RETRY_DELAY].min)
          retries += 1
        end
      end
    rescue CleverReach::Error
      raise
    rescue JSON::ParserError => e
      raise AuthenticationError, "Failed to parse authentication response: #{e.message}"
    rescue IOError, SystemCallError, Timeout::Error, SocketError, OpenSSL::SSL::SSLError, Net::OpenTimeout, Net::ReadTimeout => e
      raise AuthenticationError, "Failed to authenticate: #{e.message}"
    end

    def valid_token?
      @access_token && @expires_at && current_time < @expires_at
    end

    def token
      authenticate! unless valid_token?
      @access_token
    end

    private

    def auth_uri
      HTTP.absolute_uri(@configuration.auth_url, label: "Auth URL")
    end

    def handle_auth_response(response)
      if response.code == '200'
        data = JSON.parse(response.body)
        @access_token = data["access_token"]
        raise AuthenticationError, "Authentication response did not include an access token" if @access_token.to_s.strip.empty?

        expires_in = token_lifetime(data["expires_in"])
        refresh_margin = [60, expires_in / 2].min
        @expires_at = current_time + expires_in - refresh_margin
      else
        error_msg = "Authentication failed with status #{response.code}"
        message = ErrorParser.message(response.body)
        error_msg += ": #{message}" unless message.to_s.strip.empty?
        status_code = response.code.to_i
        if status_code >= 500 && status_code <= 599
          raise TransientAuthenticationError.new(error_msg, status_code)
        end

        raise AuthenticationError, error_msg
      end
    end

    def current_time
      @configuration.clock.call
    end

    def token_lifetime(value)
      return 3600 if value.nil?

      lifetime = Integer(value)
      lifetime.positive? ? lifetime : 3600
    rescue ArgumentError, TypeError
      3600
    end
  end
end
