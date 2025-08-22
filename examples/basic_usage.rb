#!/usr/bin/env ruby

require_relative "../lib/clever_reach"

# Configure the gem
CleverReach.configure do |config|
  config.client_id = ENV["CLEVERREACH_CLIENT_ID"]
  config.client_secret = ENV["CLEVERREACH_CLIENT_SECRET"]
  # config.api_base_url = "https://rest.cleverreach.com/v3" # Optional, this is the default
end

# Initialize the client
client = CleverReach.client

begin
  # Example 1: List all groups
  puts "=== Getting all groups ==="
  groups = client.groups.all
  puts "Found #{groups.size} groups"
  groups.each { |group| puts "- #{group['name']} (ID: #{group['id']})" }

  # Example 2: Create a new group
  puts "\n=== Creating a new group ==="
  new_group = client.groups.create(name: "Test Group from Ruby Gem")
  puts "Created group: #{new_group['name']} (ID: #{new_group['id']})"
  group_id = new_group['id']

  # Example 3: Add a recipient to the group
  puts "\n=== Adding a recipient ==="
  recipient_data = {
    email: "test@example.com",
    registered: Time.now.to_i,
    activated: Time.now.to_i,
    attributes: {
      firstname: "John",
      lastname: "Doe"
    }
  }

  recipient = client.recipients.create(group_id, recipient_data)
  puts "Added recipient: #{recipient['email']} (ID: #{recipient['id']})"

  # Example 4: Get group statistics
  puts "\n=== Group statistics ==="
  stats = client.groups.stats(group_id)
  puts "Total recipients: #{stats['total_count']}"
  puts "Active recipients: #{stats['active_count']}"

  # Example 5: List recipients in the group
  puts "\n=== Listing recipients ==="
  recipients = client.recipients.all(group_id)
  recipients.each do |rec|
    puts "- #{rec['email']} (#{rec['attributes']['firstname']} #{rec['attributes']['lastname']})"
  end

  # Cleanup: Delete the test group
  puts "\n=== Cleaning up ==="
  client.groups.destroy(group_id)
  puts "Deleted test group"

rescue CleverReach::AuthenticationError => e
  puts "Authentication failed: #{e.message}"
  puts "Please check your CLIENT_ID and CLIENT_SECRET environment variables"
rescue CleverReach::APIError => e
  puts "API Error: #{e.message}"
  puts "Status Code: #{e.status_code}" if e.status_code
rescue CleverReach::Error => e
  puts "Error: #{e.message}"
end
