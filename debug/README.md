# Debug Scripts

These scripts are local diagnostics for current CleverReach gem behavior. They use `Net::HTTP`, matching the implementation in `lib/`, and do not contain real credentials or tokens.

## Environment

Set the required values in your shell or in a local `.env` file that is not committed:

```sh
export CLEVER_REACH_CLIENT_ID="your-client-id"
export CLEVER_REACH_CLIENT_SECRET="your-client-secret"
export CLEVER_REACH_TOKEN="your-access-token"
```

Optional overrides:

```sh
export CLEVER_REACH_API_BASE_URL="https://rest.cleverreach.com/v3"
export CLEVER_REACH_AUTH_URL="https://rest.cleverreach.com/oauth/token.php"
export CLEVER_REACH_DEBUG_USER_AGENT="CleverReach Ruby Gem Debug"
```

## Scripts

- `manual_test.rb`: manually requests a client-credentials token and calls `/groups`.
- `test_auth.rb`: tests authentication through the gem client.
- `compare_approaches.rb`: compares manual Net::HTTP auth with the gem client.
- `decode_token.rb`: decodes a JWT supplied in `CLEVER_REACH_TOKEN` without printing the raw token.

Run a script with Bundler when dependencies are installed:

```sh
bundle exec ruby debug/test_auth.rb
```

