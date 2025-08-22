## [Unreleased]

### Fixed
- Resolved "Forbidden: v3 token on lower version" API error by switching from Faraday to Net::HTTP
- Fixed authentication and API call compatibility issues with CleverReach API

### Changed
**BREAKING**: Replaced `CleverReach::Client` with `CleverReach::NetHttpClient`
- Removed Faraday dependency in favor of standard library Net::HTTP for better compatibility
- Updated all examples and documentation to use the new client

### Added
`CleverReach.client` convenience method for creating client instances
- Enhanced error handling and debugging capabilities
- Comprehensive troubleshooting documentation

## [0.1.0] - 2025-08-22

- Initial release
- Client Credentials OAuth authentication  
- Groups resource with full CRUD operations
- Recipients resource with comprehensive recipient management
- Configurable API client
- Error handling with specific exception types
- RSpec test suite
