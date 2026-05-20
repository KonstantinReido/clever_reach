require "net/http"
require "uri"

module CleverReach
  module HTTP
    module_function

    def absolute_uri(url, label:)
      uri = URI(url.to_s)
      return uri if uri.is_a?(URI::HTTP) && uri.host

      raise ConfigurationError, "#{label} must be an absolute HTTP or HTTPS URL"
    rescue URI::InvalidURIError => e
      raise ConfigurationError, "#{label} is invalid: #{e.message}"
    end

    def uri_for(base_url, path, label:)
      base = base_url.to_s.sub(%r{/+\z}, "")
      normalized_path = path.to_s.sub(%r{\A/+}, "")

      absolute_uri("#{base}/#{normalized_path}", label: label)
    end

    def connection(uri, configuration)
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.use_ssl = uri.scheme == "https"
        http.open_timeout = configuration.open_timeout
        http.read_timeout = configuration.timeout
      end
    end
  end
end
