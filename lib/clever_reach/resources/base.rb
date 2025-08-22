module CleverReach
  module Resources
    class Base
      attr_reader :client

      def initialize(client)
        @client = client
      end

      private

      def get(path, params = {})
        client.get(path, params)
      end

      def post(path, data = {})
        client.post(path, data)
      end

      def put(path, data = {})
        client.put(path, data)
      end

      def delete(path)
        client.delete(path)
      end
    end
  end
end
