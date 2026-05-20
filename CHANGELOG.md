## [Unreleased]

### Fixed
- Resolved "Forbidden: v3 token on lower version" API error by switching from Faraday to Net::HTTP
- Fixed authentication and API call compatibility issues with CleverReach API
- Preserved documented status-specific errors instead of wrapping them as generic `APIError`
- Escaped dynamic resource path segments before building API URLs
- Normalized API base URL and request path joining to avoid double slashes
- Removed direct debug output from authentication request handling
- Treated whitespace-only successful response bodies as empty responses
- Preserved existing request query parameters when adding GET params
- Parsed `error_description` fields from API and authentication error responses
- Raised a clear `APIError` for unsupported internal HTTP methods
- Used HTTP status fallback messages for whitespace-only error response bodies
- Shared API error-body parsing between authentication and API responses
- Split Net::HTTP request construction into smaller internal helpers
- Shared URL validation and Net::HTTP setup between authentication and API clients

### Changed
**BREAKING**: Replaced `CleverReach::Client` with `CleverReach::NetHttpClient`
- Removed Faraday dependency in favor of standard library Net::HTTP for better compatibility
- Updated all examples and documentation to use the new client
- Kept `CleverReach::Client` as a compatibility subclass of `CleverReach::NetHttpClient`

### Added
`CleverReach.client` convenience method for creating client instances
- Enhanced error handling and debugging capabilities
- Comprehensive troubleshooting documentation
- Configurable OAuth token URL and connection timeout
- CI matrix for supported Ruby versions
- Optional explicit configuration argument for `CleverReach.client`

## [0.1.0] - 2025-08-22

- Initial release
- Client Credentials OAuth authentication  
- Groups resource with full CRUD operations
- Recipients resource with comprehensive recipient management
- Configurable API client
- Error handling with specific exception types
- RSpec test suite
