module CleverReach
  class Configuration
    attr_accessor :client_id, :client_secret, :api_base_url, :auth_url, :timeout, :open_timeout

    def initialize
      @api_base_url = "https://rest.cleverreach.com/v3"
      @auth_url = "https://rest.cleverreach.com/oauth/token.php"
      @timeout = 30
      @open_timeout = 30
    end

    def valid?
      present?(client_id) && present?(client_secret)
    end

    private

    def present?(value)
      !value.to_s.strip.empty?
    end
  end
end
