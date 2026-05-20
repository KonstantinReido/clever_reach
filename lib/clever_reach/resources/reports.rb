require_relative "base"

module CleverReach
  module Resources
    class Reports < Base
      def all(params = {})
        get(resource_path("reports"), params)
      end

      def find(report_id)
        get(resource_path("reports", report_id))
      end

      def receivers(report_id, state, params = {})
        get(resource_path("reports", report_id, "receivers", state), params)
      end

      def stats(report_id, mode, params = {})
        get(resource_path("reports", report_id, "stats", mode), params)
      end

      def destroy(report_id)
        delete(resource_path("reports", report_id))
      end
    end
  end
end
