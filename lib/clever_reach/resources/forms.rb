require_relative "base"

module CleverReach
  module Resources
    class Forms < Base
      def all
        get(resource_path("forms"))
      end

      def find(form_id)
        get(resource_path("forms", form_id))
      end

      def code(form_id, params = {})
        get(resource_path("forms", form_id, "code"), params)
      end

      def send(form_id, type, mail_data)
        post(resource_path("forms", form_id, "send", type), mail_data)
      end

      def create_from_template(group_id, type, template_data)
        post(resource_path("forms", group_id, "createfromtemplate", type), template_data)
      end

      def destroy(form_id)
        delete(resource_path("forms", form_id))
      end
    end
  end
end
