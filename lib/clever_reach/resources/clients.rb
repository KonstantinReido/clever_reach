require_relative "base"

module CleverReach
  module Resources
    class Clients < Base
      def all(params = {})
        get(resource_path("clients"), params)
      end

      def find(client_id)
        get(resource_path("clients", client_id))
      end

      def find_by_domain(domain)
        get(resource_path("clients", "domain", domain))
      end

      def active_receiver_count(client_id)
        get(resource_path("clients", client_id, "activereceivercount"))
      end

      def contingent(client_id)
        get(resource_path("clients", client_id, "contingent"))
      end

      def invoice_address(client_id)
        get(resource_path("clients", client_id, "invoiceaddress"))
      end

      def limits(client_id)
        get(resource_path("clients", client_id, "limits"))
      end

      def next_invoice_date(client_id)
        get(resource_path("clients", client_id, "nextinvoicedate"))
      end

      def update_payment_options(client_id, payment_options)
        put(resource_path("clients", client_id, "paymentoptions"), payment_options)
      end

      def update_payment_source(client_id, payment_source)
        put(resource_path("clients", client_id, "paymentsource"), payment_source)
      end

      def plan(client_id)
        get(resource_path("clients", client_id, "plan"))
      end

      def receiver_count(client_id)
        get(resource_path("clients", client_id, "receivercount"))
      end

      def users(client_id)
        get(resource_path("clients", client_id, "users"))
      end
    end
  end
end
