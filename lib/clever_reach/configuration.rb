module CleverReach
  class Configuration
    attr_accessor :client_id, :client_secret, :api_base_url, :timeout

    def initialize
      @api_base_url = "https://rest.cleverreach.com/v3"
      @timeout = 30
    end

    def valid?
      !client_id.nil? && !client_id.empty? && !client_secret.nil? && !client_secret.empty?
    end
  end
end
