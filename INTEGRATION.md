# Integration with Rails Application

## Adding to Gemfile

Add the following to your main application's `Gemfile`:

```ruby
gem 'clever_reach', path: 'vendor/gems/clever_reach'
```

Then run `bundle install`.

## Configuration

Create an initializer file `config/initializers/clever_reach.rb`:

```ruby
CleverReach.configure do |config|
  config.client_id = "your_valid_client_id"
  config.client_secret = "your_valid_client_secret"
end

client = CleverReach.client
groups = client.groups.all
puts "Found #{groups.size} groups"
```

## Environment Variables

Alternatively, you can use environment variables:

```ruby
# config/initializers/clever_reach.rb
CleverReach.configure do |config|
  config.client_id = ENV['CLEVERREACH_CLIENT_ID']
  config.client_secret = ENV['CLEVERREACH_CLIENT_SECRET']
end
```

## Service Object Example

Create a service object to handle CleverReach operations:

```ruby
# app/services/cleverreach_service.rb
class CleverreachService
  def initialize
    @client = CleverReach.client
  end

  def sync_user_to_group(user, group_id)
    recipient_data = {
      email: user.email,
      registered: user.created_at.to_i,
      activated: Time.now.to_i,
      attributes: {
        firstname: user.first_name,
        lastname: user.last_name,
        # Add more custom attributes as needed
      }
    }

    @client.recipients.create(group_id, recipient_data)
  rescue CleverReach::ValidationError => e
    Rails.logger.error "CleverReach validation error: #{e.message}"
    nil
  rescue CleverReach::APIError => e
    Rails.logger.error "CleverReach API error: #{e.message}"
    nil
  end

  def unsubscribe_user(user, group_id)
    recipients = @client.recipients.search(group_id, user.email)
    
    if recipients.any?
      recipient = recipients.first
      @client.recipients.unsubscribe(group_id, recipient['id'])
    end
  rescue CleverReach::NotFoundError
    # User not found in group, which is fine
    true
  rescue CleverReach::APIError => e
    Rails.logger.error "CleverReach API error: #{e.message}"
    false
  end

  def get_group_stats(group_id)
    @client.groups.stats(group_id)
  rescue CleverReach::APIError => e
    Rails.logger.error "CleverReach API error: #{e.message}"
    {}
  end
end
```

## Background Job Example

For handling bulk operations, consider using background jobs:

```ruby
# app/jobs/cleverreach_sync_job.rb
class CleverreachSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id, group_id)
    user = User.find(user_id)
    service = CleverreachService.new
    
    service.sync_user_to_group(user, group_id)
  end
end
```

## Controller Example

```ruby
# app/controllers/admin/newsletter_controller.rb
class Admin::NewsletterController < ApplicationController
  def sync_user
    user = User.find(params[:user_id])
    group_id = params[:group_id]
    
    service = CleverreachService.new
    result = service.sync_user_to_group(user, group_id)
    
    if result
      redirect_to admin_users_path, notice: 'User synced to CleverReach successfully'
    else
      redirect_to admin_users_path, alert: 'Failed to sync user to CleverReach'
    end
  end
end
```

## Testing

In your test suite, you can mock the CleverReach client:

```ruby
# spec/support/cleverreach_helpers.rb
RSpec.shared_context "cleverreach_mocked" do
  let(:mock_client) { instance_double(CleverReach::NetHttpClient) }
  let(:mock_groups) { instance_double(CleverReach::Resources::Groups) }
  let(:mock_recipients) { instance_double(CleverReach::Resources::Recipients) }

  before do
  allow(CleverReach::NetHttpClient).to receive(:new).and_return(mock_client)
  allow(mock_client).to receive(:groups).and_return(mock_groups)
  allow(mock_client).to receive(:recipients).and_return(mock_recipients)
  end
end
```

## Error Handling Best Practices

Always handle the specific exceptions that the gem raises:

- `CleverReach::ConfigurationError` - Missing or invalid configuration
- `CleverReach::AuthenticationError` - Invalid credentials or token issues
- `CleverReach::ValidationError` - Bad request data (400 errors)
- `CleverReach::NotFoundError` - Resource not found (404 errors)
- `CleverReach::RateLimitError` - Rate limit exceeded (429 errors)
- `CleverReach::APIError` - General API errors

This ensures your application can gracefully handle different types of failures and provide appropriate feedback to users.
