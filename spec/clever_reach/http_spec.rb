require "spec_helper"

RSpec.describe CleverReach::HTTP do
  describe ".absolute_uri" do
    it "returns absolute HTTP URIs" do
      uri = described_class.absolute_uri("https://example.test/path", label: "Test URL")

      expect(uri.scheme).to eq("https")
      expect(uri.host).to eq("example.test")
      expect(uri.path).to eq("/path")
    end

    it "raises ConfigurationError for relative URLs" do
      expect { described_class.absolute_uri("/path", label: "Test URL") }
        .to raise_error(CleverReach::ConfigurationError, "Test URL must be an absolute HTTP or HTTPS URL")
    end

    it "raises ConfigurationError for malformed URLs" do
      expect { described_class.absolute_uri("https://exa mple.test", label: "Test URL") }
        .to raise_error(CleverReach::ConfigurationError, /Test URL is invalid:/)
    end
  end

  describe ".uri_for" do
    it "joins base URLs and paths without duplicate slashes" do
      uri = described_class.uri_for("https://example.test/v3/", "/groups", label: "API base URL")

      expect(uri.to_s).to eq("https://example.test/v3/groups")
    end

    it "raises ConfigurationError when base URLs include query parameters" do
      expect { described_class.uri_for("https://example.test/v3?region=eu", "/groups", label: "API base URL") }
        .to raise_error(CleverReach::ConfigurationError, "API base URL must not include query parameters or fragments")
    end

    it "raises ConfigurationError when base URLs include fragments" do
      expect { described_class.uri_for("https://example.test/v3#groups", "/groups", label: "API base URL") }
        .to raise_error(CleverReach::ConfigurationError, "API base URL must not include query parameters or fragments")
    end
  end

  describe ".connection" do
    it "applies SSL and timeout configuration" do
      configuration = CleverReach::Configuration.new
      configuration.open_timeout = 5
      configuration.timeout = 10
      uri = described_class.absolute_uri("https://example.test/path", label: "Test URL")

      connection = described_class.connection(uri, configuration)

      expect(connection.use_ssl?).to be true
      expect(connection.open_timeout).to eq(5)
      expect(connection.read_timeout).to eq(10)
    end
  end
end
