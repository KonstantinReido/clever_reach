require "net/http"
require "uri"
require "json"

module CleverReach
  class Auth
    attr_reader :access_token, :expires_at

    def initialize(configuration)
      @configuration = configuration
      @access_token = nil
      @expires_at = nil
    end

    def authenticate!
      uri = URI(@configuration.auth_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @configuration.open_timeout
      http.read_timeout = @configuration.timeout

      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request['User-Agent'] = "CleverReach Ruby Gem #{CleverReach::VERSION}"
      request.set_form_data({
        'grant_type' => 'client_credentials',
        'client_id' => @configuration.client_id,
        'client_secret' => @configuration.client_secret
      })

      response = http.request(request)
      handle_auth_response(response)
    rescue CleverReach::Error
      raise
    rescue JSON::ParserError => e
      raise AuthenticationError, "Failed to parse authentication response: #{e.message}"
    rescue IOError, SystemCallError, Timeout::Error, SocketError, Net::OpenTimeout, Net::ReadTimeout => e
      raise AuthenticationError, "Failed to authenticate: #{e.message}"
    end

    def valid_token?
      @access_token && @expires_at && Time.now < @expires_at
    end

    def token
      authenticate! unless valid_token?
      @access_token
    end

    private

    def handle_auth_response(response)
      puts "DEBUG: Auth response status: #{response.code}" if ENV["DEBUG"]
      
      if response.code == '200'
        data = JSON.parse(response.body)
        @access_token = data["access_token"]
        raise AuthenticationError, "Authentication response did not include an access token" if @access_token.to_s.strip.empty?

        expires_in = data["expires_in"]&.to_i || 3600
        @expires_at = Time.now + expires_in - 60 # Refresh 1 minute early
        puts "DEBUG: Auth successful, token expires at #{@expires_at}" if ENV["DEBUG"]
      else
        error_msg = "Authentication failed with status #{response.code}"
        error_msg += ": #{response.body}" if response.body
        raise AuthenticationError, error_msg
      end
    end
  end
end
