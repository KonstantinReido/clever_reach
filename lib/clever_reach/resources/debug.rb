require_relative "base"

module CleverReach
  module Resources
    class Debug < Base
      def exchange
        get(resource_path("debug", "exchange"))
      end

      def ttl
        get(resource_path("debug", "ttl"))
      end

      def validate
        get(resource_path("debug", "validate"))
      end

      def whoami
        get(resource_path("debug", "whoami"))
      end
    end
  end
end
