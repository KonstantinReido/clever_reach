require_relative "base"

module CleverReach
  module Resources
    class Blacklist < Base
      def all
        get(resource_path("blacklist"))
      end

      def find(email)
        get(resource_path("blacklist", email))
      end

      def create(entry_data)
        post(resource_path("blacklist"), entry_data)
      end

      def update(entry_data)
        put(resource_path("blacklist"), entry_data)
      end

      def validate(email_data)
        post(resource_path("blacklist", "validate"), email_data)
      end

      def destroy(email)
        delete(resource_path("blacklist", email))
      end
    end
  end
end
