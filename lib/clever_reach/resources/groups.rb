require_relative "base"

module CleverReach
  module Resources
    class Groups < Base
      # Get all groups
      def all(params = {})
        get(resource_path("groups"), params)
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

      # Get advanced group statistics
      def advanced_stats(group_id)
        get(resource_path("groups", group_id, "advancedstats"))
      end

      # Get blocklisted emails for a group
      def blacklist(group_id)
        get(resource_path("groups", group_id, "blacklist"))
      end

      # Add an email to a group's blocklist
      def add_to_blacklist(group_id, blacklist_data)
        post(resource_path("groups", group_id, "blacklist"), blacklist_data)
      end

      # Remove an email from a group's blocklist
      def remove_from_blacklist(group_id, email)
        delete(resource_path("groups", group_id, "blacklist", email))
      end

      # Delete all receivers from a group
      def clear(group_id)
        delete(resource_path("groups", group_id, "clear"))
      end

      # Get forms for a group
      def forms(group_id)
        get(resource_path("groups", group_id, "forms"))
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

      # Get filters/segments for a group
      def filters(group_id)
        get(resource_path("groups", group_id, "filters"))
      end

      # Get a filter/segment
      def find_filter(group_id, filter_id)
        get(resource_path("groups", group_id, "filters", filter_id))
      end

      # Create a filter/segment
      def create_filter(group_id, filter_data)
        post(resource_path("groups", group_id, "filters"), filter_data)
      end

      # Update a filter/segment
      def update_filter(group_id, filter_id, filter_data)
        put(resource_path("groups", group_id, "filters", filter_id), filter_data)
      end

      # Delete a filter/segment
      def destroy_filter(group_id, filter_id)
        delete(resource_path("groups", group_id, "filters", filter_id))
      end

      # Get receiver count based on a filter/segment
      def filter_count(group_id, filter_id)
        get(resource_path("groups", group_id, "filters", filter_id, "count"))
      end

      # Get receivers based on a filter/segment
      def filter_receivers(group_id, filter_id, params = {})
        get(resource_path("groups", group_id, "filters", filter_id, "receivers"), params)
      end

      # Get statistics based on a filter/segment
      def filter_stats(group_id, filter_id)
        get(resource_path("groups", group_id, "filters", filter_id, "stats"))
      end
    end
  end
end
