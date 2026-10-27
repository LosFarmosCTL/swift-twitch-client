# Helix rate limiting

Inspect response headers and handle rate limits in your app.

## Overview

Each Helix invocation makes one HTTP attempt. The library parses rate-limit headers
but does not queue requests, wait for capacity, retry, or maintain shared bucket state.
Your app decides how to present a delay, cancel work, or retry a failed operation.

### Inspect a response

Async methods return ``HelixResponse``, containing the endpoint's `value` and
``HelixResponseMetadata`` from that HTTP response:

```swift
let response = try await twitch.helix(for: .getUsers(userLogins: ["forsen"]))
let users = response.value

if let rateLimit = response.metadata.rateLimit {
  print(rateLimit.remaining)
  print(rateLimit.resetAt)
}
```

This applies to instance and static calls, including raw-body endpoints. Empty-body
endpoints return `HelixResponse<Void>`; their return value can be discarded.
Completion handlers receive `Result<HelixResponse<Value>, HelixError>`, including
`HelixResponse<Void>` for empty-body endpoints.

``HelixResponseMetadata/statusCode`` is the actual HTTP status.
``HelixResponseMetadata/rateLimit`` is `nil` when no valid rate-limit fields were
returned. ``HelixRateLimit`` exposes optional `limit`, `remaining`, and `resetAt`
fields alongside `observedAt`, the local time the response was processed. Missing,
negative, overflowing, or malformed fields remain `nil` independently; they do not
fail an otherwise successful request.

These are observations from a single response. They are not an estimate of current
capacity, and responses to concurrent requests can arrive out of order. A successful
response reporting zero remaining points does not delay subsequent requests.

### Handle HTTP 429

Every HTTP 429 throws ``HelixError/rateLimited(_:)``, even if the response body is
empty or malformed:

```swift
do {
  let response = try await twitch.helix(for: .getUsers(userLogins: ["forsen"]))
  print(response.value)
} catch HelixError.rateLimited(let error) {
  print(error.message ?? "Twitch rejected the request due to a rate limit.")
  print(error.metadata.rateLimit?.resetAt)
  // Decide in your app whether and when to retry.
}
```

``HelixRateLimitError`` includes the same response metadata, Twitch's error name
and message when decodable, and the unmodified `responseData`. Other HTTP errors
continue to use the existing Helix error cases. Cancellation throws
`CancellationError`; completion handlers receive `.cancelled`.

Some endpoints have separate cooldowns or restrictions. A 429 does not necessarily
mean the bucket described by the headers is exhausted, so `resetAt` is not a
universal retry time. Retrying mutations also requires care: retry decisions belong
with the caller that understands the operation.

EventSub uses the same Helix request path for subscriptions, without separate
rate-limit handling. A rate-limited subscription request fails setup through the
existing error path.

For Twitch's rate-limit semantics, see the
[API guide](https://dev.twitch.tv/docs/api/guide/#twitch-rate-limits).
