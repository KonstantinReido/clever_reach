# CleverReach

A Ruby gem that provides a convenient wrapper for the CleverReach REST API using Client Credentials authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clever_reach'
```

And then execute:

    $ bundle install

## Configuration

Configure the gem with your CleverReach API credentials:

```ruby
CleverReach.configure do |config|
  config.client_id = "your_client_id"
  config.client_secret = "your_client_secret"
  config.api_base_url = "https://rest.cleverreach.com/v3" # Optional, defaults to this
  config.auth_url = "https://rest.cleverreach.com/oauth/token.php" # Optional, defaults to this
  config.timeout = 30 # Optional read timeout in seconds
  config.open_timeout = 30 # Optional connection timeout in seconds
  config.user_agent = "My App" # Optional, defaults to "CleverReach Ruby Gem <version>"
  config.clock = -> { Time.now } # Optional, used for token expiry checks
end
```

## Usage

### Basic Usage

```ruby
# Initialize the client
client = CleverReach::NetHttpClient.new
# or use the convenience method
client = CleverReach.client
# or pass an explicit configuration
client = CleverReach.client(custom_configuration)

# Get all groups
groups = client.groups.all

# Create a new group
group = client.groups.create(name: "My Group")

# Get recipients from a group
recipients = client.recipients.all(group_id)

# Add a recipient to a group
recipient = client.recipients.create(
  group_id,
  {
    email: "user@example.com",
    attributes: {
      firstname: "John",
      lastname: "Doe"
    }
  }
)
```

### Error Handling

The gem raises specific exceptions for different error types:

```ruby
begin
  client.groups.create(name: "Test Group")
rescue CleverReach::AuthenticationError => e
  # Handle authentication errors
rescue CleverReach::ValidationError => e
  # Handle validation errors
rescue CleverReach::APIError => e
  # Handle other API errors
end
```

**Note:** This gem uses Net::HTTP directly instead of Faraday due to compatibility issues with CleverReach's API server. This ensures reliable communication with their API endpoints.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome.

## Troubleshooting

If you encounter issues with authentication or API calls, please see [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common solutions.

Common issues:
- **"invalid_client"**: Check your Client ID and Client Secret
- **"Forbidden: v3 token on lower version"**: Your account might not have v3 API access
- **404 errors**: Verify the API base URL for your account region

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
