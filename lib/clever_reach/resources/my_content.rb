require_relative "base"

module CleverReach
  module Resources
    class MyContent < Base
      def all
        get(resource_path("mycontent"))
      end

      def find(content_id)
        get(resource_path("mycontent", content_id))
      end

      def create(content_data)
        post(resource_path("mycontent"), content_data)
      end

      def update(content_id, content_data)
        put(resource_path("mycontent", content_id), content_data)
      end

      def destroy(content_id)
        delete(resource_path("mycontent", content_id))
      end
    end
  end
end
