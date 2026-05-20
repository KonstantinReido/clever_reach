# CleverReach API Setup and Troubleshooting

## Getting API Credentials

1. **Log in to your CleverReach account**
2. **Go to Account → Integrations → REST API**
3. **Create a new OAuth App:**
   - Name: Your application name
   - Authorization callback URL: Not needed for Client Credentials flow
   - Scopes: Select the appropriate scopes you need

4. **Note down your credentials:**
   - Client ID
   - Client Secret

## Common Issues and Solutions

### Issue 1: "invalid_client" Error
**Cause:** Wrong credentials or incorrect API setup

**Solutions:**
- Verify your Client ID and Client Secret are correct
- Make sure you're using the OAuth app credentials (not user credentials)
- Ensure your OAuth app has the necessary scopes enabled

### Issue 2: "Forbidden: v3 token on lower version" Error
**Cause:** API version mismatch

**Solutions:**
- Make sure your OAuth app is configured for API v3
- Check if your CleverReach account has v3 API access
- Some older accounts might be limited to v2 API

### Issue 3: 404 Errors on API Endpoints
**Cause:** Incorrect API base URL or endpoint

**Solutions:**
- Verify the API base URL is correct for your account region
- Some accounts might use different base URLs (e.g., eu1.rest.cleverreach.com)

## Debugging Steps

### Step 1: Test Your Credentials
```ruby
require 'net/http'
require 'uri'
require 'json'

# Test authentication manually
uri = URI('https://rest.cleverreach.com/oauth/token.php')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = true

request = Net::HTTP::Post.new(uri)
request.set_form_data({
  'grant_type' => 'client_credentials',
  'client_id' => 'YOUR_CLIENT_ID',
  'client_secret' => 'YOUR_CLIENT_SECRET'
})

response = http.request(request)
puts "Status: #{response.code}"
puts "Body: #{response.body}"
```

### Step 2: Check API Version Compatibility
If you get authentication working but API calls fail with version errors:

```ruby
# Try with different base URLs
CleverReach.configure do |config|
  config.client_id = ENV.fetch("CLEVER_REACH_CLIENT_ID")
  config.client_secret = ENV.fetch("CLEVER_REACH_CLIENT_SECRET")
  # Try these alternatives if the default doesn't work:
  # config.api_base_url = "https://rest.cleverreach.com/v2"
  # config.api_base_url = "https://eu1.rest.cleverreach.com/v3"
  # config.api_base_url = "https://us1.rest.cleverreach.com/v3"
end
```

### Step 3: Contact CleverReach Support
If none of the above work, you may need to:
1. Verify your account has API access enabled
2. Check if your account is on the correct data center
3. Confirm your OAuth app configuration with CleverReach support

## Working Example
Once you have valid credentials:

```ruby
CleverReach.configure do |config|
  config.client_id = ENV.fetch("CLEVER_REACH_CLIENT_ID")
  config.client_secret = ENV.fetch("CLEVER_REACH_CLIENT_SECRET")
end

client = CleverReach.client
groups = client.groups.all
puts "Found #{groups.size} groups"
```
