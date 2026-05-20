require_relative "base"

module CleverReach
  module Resources
    class Recipients < Base
      # Get all recipients from a group
      def all(group_id, params = {})
        get(resource_path("groups", group_id, "receivers"), params)
      end

      # Get receivers from a group using the documented POST endpoint
      def list(group_id, filter_data = {})
        post(resource_path("groups", group_id, "get_receivers"), filter_data)
      end

      # Get a specific recipient from a group
      def find(group_id, recipient_id)
        get(resource_path("groups", group_id, "receivers", recipient_id))
      end

      # Create/add a recipient to a group
      def create(group_id, recipient_data)
        post(resource_path("groups", group_id, "receivers"), recipient_data)
      end

      # Batch insert recipients
      def batch_create(group_id, recipients_data)
        post(resource_path("groups", group_id, "receivers", "insert"), recipients_data)
      end

      # Delete multiple recipients from a group
      def batch_destroy(group_id, recipients_data)
        post(resource_path("groups", group_id, "receivers", "delete"), recipients_data)
      end

      # Update multiple recipients in a group
      def batch_update(group_id, recipients_data)
        put(resource_path("groups", group_id, "receivers", "update"), recipients_data)
      end

      # Update multiple recipients and manipulate data
      def batch_update_plus(group_id, recipients_data)
        put(resource_path("groups", group_id, "receivers", "updateplus"), recipients_data)
      end

      # Update or create multiple recipients in a group
      def batch_upsert(group_id, recipients_data)
        post(resource_path("groups", group_id, "receivers", "upsert"), recipients_data)
      end

      # Update/create multiple recipients and manipulate data
      def batch_upsert_plus(group_id, recipients_data)
        post(resource_path("groups", group_id, "receivers", "upsertplus"), recipients_data)
      end

      # Update a recipient
      def update(group_id, recipient_id, recipient_data)
        put(resource_path("groups", group_id, "receivers", recipient_id), recipient_data)
      end

      # Delete a recipient from a group
      def destroy(group_id, recipient_id)
        delete(resource_path("groups", group_id, "receivers", recipient_id))
      end

      # Set recipient as active
      def activate(group_id, recipient_id)
        put(resource_path("groups", group_id, "receivers", recipient_id, "activate"))
      end

      # Set recipient as inactive
      def deactivate(group_id, recipient_id)
        put(resource_path("groups", group_id, "receivers", recipient_id, "deactivate"))
      end

      # Update a recipient attribute value within a group
      def update_attribute(group_id, recipient_id, attribute_id, attribute_data)
        put(resource_path("groups", group_id, "receivers", recipient_id, "attributes", attribute_id), attribute_data)
      end

      # Get recipient events (opens, clicks, etc.)
      def events(group_id, recipient_id, params = {})
        get(resource_path("groups", group_id, "receivers", recipient_id, "events"), params)
      end

      # Add an event to a recipient within a group
      def create_event(group_id, recipient_id, event_data)
        post(resource_path("groups", group_id, "receivers", recipient_id, "events"), event_data)
      end

      # Get orders for a recipient within a group
      def orders(group_id, recipient_id)
        get(resource_path("groups", group_id, "receivers", recipient_id, "orders"))
      end

      # Add an order to a recipient within a group
      def create_order(group_id, recipient_id, order_data)
        post(resource_path("groups", group_id, "receivers", recipient_id, "orders"), order_data)
      end

      # Update an order for a recipient within a group
      def update_order(group_id, recipient_id, order_id, order_data)
        put(resource_path("groups", group_id, "receivers", recipient_id, "orders", order_id), order_data)
      end

      # Delete an order for a recipient within a group
      def destroy_order(group_id, recipient_id, order_id)
        delete(resource_path("groups", group_id, "receivers", recipient_id, "orders", order_id))
      end

      # Get a receiver by global pool ID or email.
      def find_global(recipient_id, params = {})
        get(resource_path("receivers", recipient_id), params)
      end

      # Delete a receiver by global pool ID.
      def destroy_global(recipient_id, params = {})
        delete(resource_path("receivers", recipient_id), params)
      end

      # Get attributes for a global receiver.
      def attributes(recipient_id, params = {})
        get(resource_path("receivers", recipient_id, "attributes"), params)
      end

      # Update a global receiver attribute value.
      def update_global_attribute(recipient_id, attribute_id, attribute_data)
        put(resource_path("receivers", recipient_id, "attributes", attribute_id), attribute_data)
      end

      # Clone a receiver and change its email address.
      def clone(recipient_id, clone_data)
        post(resource_path("receivers", recipient_id, "clone"), clone_data)
      end

      # Change a receiver's email address.
      def change_email(recipient_id, email_data)
        put(resource_path("receivers", recipient_id, "email"), email_data)
      end

      # Get groups for a global receiver.
      def groups(recipient_id, params = {})
        get(resource_path("receivers", recipient_id, "groups"), params)
      end

      # Get orders for a global receiver.
      def global_orders(recipient_id, params = {})
        get(resource_path("receivers", recipient_id, "orders"), params)
      end

      # Get events for a global receiver.
      def global_events(recipient_id, params = {})
        get(resource_path("receivers", recipient_id, "events"), params)
      end

      # Add an event to a global receiver.
      def create_global_event(recipient_id, event_data)
        post(resource_path("receivers", recipient_id, "events"), event_data)
      end

      # Add an order to a global receiver.
      def create_global_order(recipient_id, order_data)
        post(resource_path("receivers", recipient_id, "orders"), order_data)
      end

      # Update an order for a global receiver.
      def update_global_order(recipient_id, order_id, order_data)
        put(resource_path("receivers", recipient_id, "orders", order_id), order_data)
      end

      # Delete an order for a global receiver.
      def destroy_global_order(recipient_id, order_id)
        delete(resource_path("receivers", recipient_id, "orders", order_id))
      end

      # Get all bounced receivers.
      def bounced(params = {})
        get(resource_path("receivers", "bounced"), params)
      end

      # Delete multiple global receivers.
      def destroy_multiple(recipients_data)
        post(resource_path("receivers", "delete"), recipients_data)
      end

      # Get receivers using a runtime filter.
      def filter(filter_data)
        post(resource_path("receivers", "filter"), filter_data)
      end

      # Validate a list of email addresses.
      def valid?(email_data)
        post(resource_path("receivers", "isvalid"), email_data)
      end
    end
  end
end
