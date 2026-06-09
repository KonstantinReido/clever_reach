require "uri"

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

      def delete(path, params = {})
        params.empty? ? client.delete(path) : client.delete(path, params)
      end

      def resource_path(*segments)
        "/#{segments.map { |segment| path_segment(segment) }.join("/")}"
      end

      def path_segment(value)
        raise ArgumentError, "Path segments cannot be nil" if value.nil?

        URI.encode_www_form_component(value.to_s).gsub("+", "%20")
      end
    end
  end
end
