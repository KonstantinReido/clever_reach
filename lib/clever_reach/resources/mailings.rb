require_relative "base"

module CleverReach
  module Resources
    class Mailings < Base
      def all(params = {})
        get(resource_path("mailings"), params)
      end

      def find(mailing_id)
        get(resource_path("mailings", mailing_id))
      end

      def create(mailing_data)
        post(resource_path("mailings"), mailing_data)
      end

      def update(mailing_id, mailing_data)
        put(resource_path("mailings", mailing_id), mailing_data)
      end

      def channels
        get(resource_path("mailings", "channel"))
      end

      def channel(channel_id)
        get(resource_path("mailings", "channel", channel_id))
      end

      def destroy_channel(channel_id)
        delete(resource_path("mailings", "channel", channel_id))
      end

      def create_template(template_data)
        post(resource_path("mailings", "template"), template_data)
      end

      def agency_templates
        get(resource_path("mailings", "templates", "agency"))
      end

      def user_templates
        get(resource_path("mailings", "templates", "user"))
      end

      def links(mailing_id)
        get(resource_path("mailings", mailing_id, "links"))
      end

      def orders(mailing_id)
        get(resource_path("mailings", mailing_id, "orders"))
      end

      def random_receiver(mailing_id)
        get(resource_path("mailings", mailing_id, "randomreceiver"))
      end

      def send_preview(mailing_id, preview_data)
        post(resource_path("mailings", mailing_id, "sendpreview"), preview_data)
      end
    end
  end
end
