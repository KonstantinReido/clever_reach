require_relative "base"

module CleverReach
  module Resources
    class Groups < Base
      # Get all groups
      def all
        get(resource_path("groups"))
      end

      # Get a specific group by ID
      def find(group_id)
        get(resource_path("groups", group_id))
      end

      # Create a new group
      def create(attributes = {})
        post(resource_path("groups"), attributes)
      end

      # Update a group
      def update(group_id, attributes = {})
        put(resource_path("groups", group_id), attributes)
      end

      # Delete a group
      def destroy(group_id)
        delete(resource_path("groups", group_id))
      end

      # Get group statistics
      def stats(group_id)
        get(resource_path("groups", group_id, "stats"))
      end

      # Get group attributes/fields
      def attributes(group_id)
        get(resource_path("groups", group_id, "attributes"))
      end

      # Create a new group attribute
      def create_attribute(group_id, attribute_data)
        post(resource_path("groups", group_id, "attributes"), attribute_data)
      end

      # Update a group attribute
      def update_attribute(group_id, attribute_id, attribute_data)
        put(resource_path("groups", group_id, "attributes", attribute_id), attribute_data)
      end

      # Delete a group attribute
      def destroy_attribute(group_id, attribute_id)
        delete(resource_path("groups", group_id, "attributes", attribute_id))
      end
    end
  end
end
