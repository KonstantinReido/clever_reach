require_relative "clever_reach/version"
require_relative "clever_reach/configuration"
require_relative "clever_reach/errors"
require_relative "clever_reach/error_parser"
require_relative "clever_reach/http"
require_relative "clever_reach/auth"
require_relative "clever_reach/resources/base"
require_relative "clever_reach/resources/groups"
require_relative "clever_reach/resources/recipients"
require_relative "clever_reach/net_http_client"

module CleverReach
  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    # Create a client using Net::HTTP (more compatible)
    def client(configuration = nil)
      NetHttpClient.new(configuration)
    end
  end
end
