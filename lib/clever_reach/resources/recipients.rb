module CleverReach
  module Resources
    class Recipients < Base
      # Get all recipients from a group
      def all(group_id, params = {})
        get(resource_path("groups", group_id, "receivers"), params)
      end

      # Get a specific recipient from a group
      def find(group_id, recipient_id)
        get(resource_path("groups", group_id, "receivers", recipient_id))
      end

      # Search recipients in a group
      def search(group_id, query, params = {})
        get(resource_path("groups", group_id, "receivers", "filter"), params.merge(query: query))
      end

      # Create/add a recipient to a group
      def create(group_id, recipient_data)
        post(resource_path("groups", group_id, "receivers"), recipient_data)
      end

      # Batch insert recipients
      def batch_create(group_id, recipients_data)
        post(resource_path("groups", group_id, "receivers", "insert"), recipients_data)
      end

      # Update a recipient
      def update(group_id, recipient_id, recipient_data)
        put(resource_path("groups", group_id, "receivers", recipient_id), recipient_data)
      end

      # Delete a recipient from a group
      def destroy(group_id, recipient_id)
        delete(resource_path("groups", group_id, "receivers", recipient_id))
      end

      # Unsubscribe a recipient
      def unsubscribe(group_id, recipient_id)
        post(resource_path("groups", group_id, "receivers", recipient_id, "unsubscribe"))
      end

      # Resubscribe a recipient
      def resubscribe(group_id, recipient_id)
        post(resource_path("groups", group_id, "receivers", recipient_id, "subscribe"))
      end

      # Set recipient as active
      def activate(group_id, recipient_id)
        put(resource_path("groups", group_id, "receivers", recipient_id, "setactive"))
      end

      # Set recipient as inactive
      def deactivate(group_id, recipient_id)
        put(resource_path("groups", group_id, "receivers", recipient_id, "setinactive"))
      end

      # Get recipient events (opens, clicks, etc.)
      def events(group_id, recipient_id, params = {})
        get(resource_path("groups", group_id, "receivers", recipient_id, "events"), params)
      end

      # Trigger a double opt-in email
      def trigger_double_opt_in(group_id, recipient_id, options = {})
        post(resource_path("groups", group_id, "receivers", recipient_id, "sendactivationmail"), options)
      end
    end
  end
end
