require_relative "base"

module CleverReach
  module Resources
    class Oauth < Base
      def revoke_token
        delete(resource_path("oauth", "token"))
      end
    end
  end
end
