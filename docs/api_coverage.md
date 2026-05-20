# CleverReach REST API v3 Coverage

Source: `https://rest.cleverreach.com/v3/explorer/swagger.json`

Last reviewed: 2026-05-20

The Swagger document currently exposes 93 documented paths under `/v3`. The gem keeps `api_base_url` defaulted to `https://rest.cleverreach.com/v3`, so wrapper paths intentionally omit the `/v3` prefix.

## Summary

| Area | Swagger paths | Status | Resource |
| --- | ---: | --- | --- |
| Attributes | 3 | Implemented | `client.attributes` |
| Blacklist | 3 | Implemented | `client.blacklist`, `client.groups` |
| Bounces | 1 | Implemented | `client.bounces`, `client.recipients` |
| Clients | 13 | Implemented | `client.clients` |
| Debug | 4 | Implemented | `client.debug` |
| Forms | 5 | Implemented | `client.forms`, `client.groups` |
| Groups | 31 | Implemented | `client.groups`, `client.recipients` |
| Mailings | 11 | Implemented | `client.mailings` |
| My Content | 2 | Implemented | `client.my_content` |
| OAuth | 1 | Implemented | `client.oauth` |
| Global Receivers | 15 | Implemented | `client.recipients` |
| Reports | 4 | Implemented | `client.reports` |

## Already Implemented Before This Pass

The gem already exposed wrappers for:

| Endpoint | Existing method |
| --- | --- |
| `GET /groups` | `client.groups.all` |
| `POST /groups` | `client.groups.create` |
| `GET /groups/{id}` | `client.groups.find` |
| `PUT /groups/{id}` | `client.groups.update` |
| `DELETE /groups/{id}` | `client.groups.destroy` |
| `GET /groups/{id}/stats` | `client.groups.stats` |
| `GET /groups/{group_id}/attributes` | `client.groups.attributes` |
| `POST /groups/{group_id}/attributes` | `client.groups.create_attribute` |
| `PUT /groups/{group_id}/attributes/{id}` | `client.groups.update_attribute` |
| `DELETE /groups/{group_id}/attributes/{id}` | `client.groups.destroy_attribute` |
| `GET /groups/{group_id}/receivers` | `client.recipients.all` |
| `GET /groups/{group_id}/receivers/{pool_id}` | `client.recipients.find` |
| `POST /groups/{group_id}/receivers` | `client.recipients.create` |
| `POST /groups/{group_id}/receivers/insert` | `client.recipients.batch_create` |
| `PUT /groups/{group_id}/receivers/{id}` | `client.recipients.update` |
| `DELETE /groups/{group_id}/receivers/{pool_id}` | `client.recipients.destroy` |
| `GET /groups/{group_id}/receivers/{pool_id}/events` | `client.recipients.events` |

## Newly Covered Endpoints

### Attributes

| Endpoint | Method |
| --- | --- |
| `GET /attributes` | `client.attributes.all(params = {})` |
| `POST /attributes` | `client.attributes.create(attribute_data)` |
| `GET /attributes/limits` | `client.attributes.limits` |
| `GET /attributes/{id}` | `client.attributes.find(attribute_id)` |
| `PUT /attributes/{id}` | `client.attributes.update(attribute_id, attribute_data)` |
| `DELETE /attributes/{id}` | `client.attributes.destroy(attribute_id)` |

### Account Blacklist

| Endpoint | Method |
| --- | --- |
| `GET /blacklist` | `client.blacklist.all` |
| `POST /blacklist` | `client.blacklist.create(entry_data)` |
| `PUT /blacklist` | `client.blacklist.update(entry_data)` |
| `POST /blacklist/validate` | `client.blacklist.validate(email_data)` |
| `GET /blacklist/{email}` | `client.blacklist.find(email)` |
| `DELETE /blacklist/{email}` | `client.blacklist.destroy(email)` |

### Bounces, Clients, Debug

| Endpoint | Method |
| --- | --- |
| `GET /bounces` | `client.bounces.all(params = {})` |
| `GET /clients` | `client.clients.all(params = {})` |
| `GET /clients/domain/{domain}` | `client.clients.find_by_domain(domain)` |
| `GET /clients/{id}` | `client.clients.find(client_id)` |
| `GET /clients/{id}/activereceivercount` | `client.clients.active_receiver_count(client_id)` |
| `GET /clients/{id}/contingent` | `client.clients.contingent(client_id)` |
| `GET /clients/{id}/invoiceaddress` | `client.clients.invoice_address(client_id)` |
| `GET /clients/{id}/limits` | `client.clients.limits(client_id)` |
| `GET /clients/{id}/nextinvoicedate` | `client.clients.next_invoice_date(client_id)` |
| `PUT /clients/{id}/paymentoptions` | `client.clients.update_payment_options(client_id, payment_options)` |
| `PUT /clients/{id}/paymentsource` | `client.clients.update_payment_source(client_id, payment_source)` |
| `GET /clients/{id}/plan` | `client.clients.plan(client_id)` |
| `GET /clients/{id}/receivercount` | `client.clients.receiver_count(client_id)` |
| `GET /clients/{id}/users` | `client.clients.users(client_id)` |
| `GET /debug/exchange` | `client.debug.exchange` |
| `GET /debug/ttl` | `client.debug.ttl` |
| `GET /debug/validate` | `client.debug.validate` |
| `GET /debug/whoami` | `client.debug.whoami` |

### Forms

| Endpoint | Method |
| --- | --- |
| `GET /forms` | `client.forms.all` |
| `POST /forms/{form_id}/send/{type}` | `client.forms.send(form_id, type, mail_data)` |
| `POST /forms/{group_id}/createfromtemplate/{type}` | `client.forms.create_from_template(group_id, type, template_data)` |
| `GET /forms/{id}` | `client.forms.find(form_id)` |
| `DELETE /forms/{id}` | `client.forms.destroy(form_id)` |
| `GET /forms/{id}/code` | `client.forms.code(form_id, params = {})` |

### Groups, Filters, and Group Receivers

| Endpoint | Method |
| --- | --- |
| `GET /groups/{group_id}/advancedstats` | `client.groups.advanced_stats(group_id)` |
| `GET /groups/{group_id}/blacklist` | `client.groups.blacklist(group_id)` |
| `POST /groups/{group_id}/blacklist` | `client.groups.add_to_blacklist(group_id, blacklist_data)` |
| `DELETE /groups/{id}/blacklist/{email}` | `client.groups.remove_from_blacklist(group_id, email)` |
| `DELETE /groups/{id}/clear` | `client.groups.clear(group_id)` |
| `GET /groups/{id}/forms` | `client.groups.forms(group_id)` |
| `GET /groups/{group_id}/filters` | `client.groups.filters(group_id)` |
| `POST /groups/{group_id}/filters` | `client.groups.create_filter(group_id, filter_data)` |
| `GET /groups/{group_id}/filters/{filter_id}` | `client.groups.find_filter(group_id, filter_id)` |
| `PUT /groups/{group_id}/filters/{filter_id}` | `client.groups.update_filter(group_id, filter_id, filter_data)` |
| `DELETE /groups/{group_id}/filters/{filter_id}` | `client.groups.destroy_filter(group_id, filter_id)` |
| `GET /groups/{group_id}/filters/{filter_id}/count` | `client.groups.filter_count(group_id, filter_id)` |
| `GET /groups/{group_id}/filters/{filter_id}/receivers` | `client.groups.filter_receivers(group_id, filter_id, params = {})` |
| `GET /groups/{group_id}/filters/{filter_id}/stats` | `client.groups.filter_stats(group_id, filter_id)` |
| `POST /groups/{group_id}/get_receivers` | `client.recipients.list(group_id, filter_data = {})` |
| `POST /groups/{group_id}/receivers/delete` | `client.recipients.batch_destroy(group_id, recipients_data)` |
| `PUT /groups/{group_id}/receivers/update` | `client.recipients.batch_update(group_id, recipients_data)` |
| `PUT /groups/{group_id}/receivers/updateplus` | `client.recipients.batch_update_plus(group_id, recipients_data)` |
| `POST /groups/{group_id}/receivers/upsert` | `client.recipients.batch_upsert(group_id, recipients_data)` |
| `POST /groups/{group_id}/receivers/upsertplus` | `client.recipients.batch_upsert_plus(group_id, recipients_data)` |
| `PUT /groups/{group_id}/receivers/{id}/activate` | `client.recipients.activate(group_id, recipient_id)` |
| `PUT /groups/{group_id}/receivers/{pool_id}/attributes/{id}` | `client.recipients.update_attribute(group_id, recipient_id, attribute_id, attribute_data)` |
| `PUT /groups/{group_id}/receivers/{pool_id}/deactivate` | `client.recipients.deactivate(group_id, recipient_id)` |
| `POST /groups/{group_id}/receivers/{pool_id}/events` | `client.recipients.create_event(group_id, recipient_id, event_data)` |
| `GET /groups/{group_id}/receivers/{pool_id}/orders` | `client.recipients.orders(group_id, recipient_id)` |
| `POST /groups/{group_id}/receivers/{pool_id}/orders` | `client.recipients.create_order(group_id, recipient_id, order_data)` |
| `PUT /groups/{group_id}/receivers/{pool_id}/orders/{id}` | `client.recipients.update_order(group_id, recipient_id, order_id, order_data)` |
| `DELETE /groups/{group_id}/receivers/{pool_id}/orders/{id}` | `client.recipients.destroy_order(group_id, recipient_id, order_id)` |

### Mailings, My Content, OAuth, Reports

| Endpoint | Method |
| --- | --- |
| `GET /mailings` | `client.mailings.all(params = {})` |
| `POST /mailings` | `client.mailings.create(mailing_data)` |
| `GET /mailings/{id}` | `client.mailings.find(mailing_id)` |
| `PUT /mailings/{id}` | `client.mailings.update(mailing_id, mailing_data)` |
| `GET /mailings/channel` | `client.mailings.channels` |
| `GET /mailings/channel/{id}` | `client.mailings.channel(channel_id)` |
| `DELETE /mailings/channel/{id}` | `client.mailings.destroy_channel(channel_id)` |
| `POST /mailings/template` | `client.mailings.create_template(template_data)` |
| `GET /mailings/templates/agency` | `client.mailings.agency_templates` |
| `GET /mailings/templates/user` | `client.mailings.user_templates` |
| `GET /mailings/{id}/links` | `client.mailings.links(mailing_id)` |
| `GET /mailings/{id}/orders` | `client.mailings.orders(mailing_id)` |
| `GET /mailings/{id}/randomreceiver` | `client.mailings.random_receiver(mailing_id)` |
| `POST /mailings/{id}/sendpreview` | `client.mailings.send_preview(mailing_id, preview_data)` |
| `GET /mycontent` | `client.my_content.all` |
| `POST /mycontent` | `client.my_content.create(content_data)` |
| `GET /mycontent/{id}` | `client.my_content.find(content_id)` |
| `PUT /mycontent/{id}` | `client.my_content.update(content_id, content_data)` |
| `DELETE /mycontent/{id}` | `client.my_content.destroy(content_id)` |
| `DELETE /oauth/token` | `client.oauth.revoke_token` |
| `GET /reports` | `client.reports.all(params = {})` |
| `GET /reports/{id}` | `client.reports.find(report_id)` |
| `DELETE /reports/{id}` | `client.reports.destroy(report_id)` |
| `GET /reports/{id}/receivers/{state}` | `client.reports.receivers(report_id, state, params = {})` |
| `GET /reports/{id}/stats/{mode}` | `client.reports.stats(report_id, mode, params = {})` |

### Global Receivers

| Endpoint | Method |
| --- | --- |
| `GET /receivers/bounced` | `client.recipients.bounced(params = {})` |
| `POST /receivers/delete` | `client.recipients.destroy_multiple(recipients_data)` |
| `POST /receivers/filter` | `client.recipients.filter(filter_data)` |
| `POST /receivers/isvalid` | `client.recipients.valid?(email_data)` |
| `GET /receivers/{id}` | `client.recipients.find_global(recipient_id, params = {})` |
| `GET /receivers/{id}/attributes` | `client.recipients.attributes(recipient_id, params = {})` |
| `POST /receivers/{id}/clone` | `client.recipients.clone(recipient_id, clone_data)` |
| `PUT /receivers/{id}/email` | `client.recipients.change_email(recipient_id, email_data)` |
| `GET /receivers/{id}/groups` | `client.recipients.groups(recipient_id, params = {})` |
| `GET /receivers/{id}/orders` | `client.recipients.global_orders(recipient_id, params = {})` |
| `DELETE /receivers/{pool_id}` | `client.recipients.destroy_global(recipient_id, params = {})` |
| `PUT /receivers/{pool_id}/attributes/{id}` | `client.recipients.update_global_attribute(recipient_id, attribute_id, attribute_data)` |
| `GET /receivers/{pool_id}/events` | `client.recipients.global_events(recipient_id, params = {})` |
| `POST /receivers/{pool_id}/events` | `client.recipients.create_global_event(recipient_id, event_data)` |
| `POST /receivers/{pool_id}/orders` | `client.recipients.create_global_order(recipient_id, order_data)` |
| `PUT /receivers/{pool_id}/orders/{id}` | `client.recipients.update_global_order(recipient_id, order_id, order_data)` |
| `DELETE /receivers/{pool_id}/orders/{id}` | `client.recipients.destroy_global_order(recipient_id, order_id)` |

## Inconsistencies Found

| Area | Finding | Resolution |
| --- | --- | --- |
| Group receiver activation | Existing code used `/setactive` and `/setinactive`; Swagger documents `/activate` and `/deactivate`. | `client.recipients.activate` and `client.recipients.deactivate` now use the documented paths. |
| DELETE query params | Existing client did not support query params on DELETE requests. | `NetHttpClient#delete(path, params = {})` now supports query params while preserving the old one-argument call style. |
| Swagger path prefix | Swagger paths include `/v3`; gem resource paths omit it. | Kept unchanged because `Configuration#api_base_url` already includes `/v3`. |

## Test Approach

Specs continue to avoid real API calls. Resource specs use `instance_double(CleverReach::NetHttpClient)` to verify path, query params, and request body delegation. HTTP specs use WebMock for request/response behavior and error handling.
