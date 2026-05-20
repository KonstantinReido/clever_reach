require_relative "base"

module CleverReach
  module Resources
    class Attributes < Base
      def all(params = {})
        get(resource_path("attributes"), params)
      end

      def limits
        get(resource_path("attributes", "limits"))
      end

      def find(attribute_id)
        get(resource_path("attributes", attribute_id))
      end

      def create(attribute_data)
        post(resource_path("attributes"), attribute_data)
      end

      def update(attribute_id, attribute_data)
        put(resource_path("attributes", attribute_id), attribute_data)
      end

      def destroy(attribute_id)
        delete(resource_path("attributes", attribute_id))
      end
    end
  end
end
