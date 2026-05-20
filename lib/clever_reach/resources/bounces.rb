require_relative "base"

module CleverReach
  module Resources
    class Bounces < Base
      def all(params = {})
        get(resource_path("bounces"), params)
      end
    end
  end
end
