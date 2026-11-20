# Helix Rate Limiting

Inspect per-response rate-limit headers and handle HTTP 429 errors deliberately in your app.

## Overview

Each Helix call makes **one HTTP attempt**. The library parses Twitch's rate-limit headers and
surfaces HTTP 429 as a typed error, but it does not queue requests, sleep waiting for capacity,
automatically retry failed calls, or maintain a shared local bucket estimate.

Keeping retry policy in your application is intentional: only your caller knows whether an
operation is safe to retry (especially for mutations like sending chat messages, banning users,
or starting commercials), whether the user is still waiting on a screen, or how to back off.

### Inspecting Rate-Limit Headers

Every Helix call returns a ``HelixResponse`` whose ``HelixResponse/metadata`` carries the HTTP
``HelixResponseMetadata/statusCode`` and an optional ``HelixRateLimit`` parsed from Twitch's
`Ratelimit-Limit`, `Ratelimit-Remaining`, and `Ratelimit-Reset` headers:

```swift
let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
let users = response.value

if let rateLimit = response.metadata.rateLimit {
  print("Remaining: \(rateLimit.remaining ?? -1) / \(rateLimit.limit ?? -1)")
  print("Resets at: \(rateLimit.resetAt?.description ?? "unknown")")
}
```

This applies equally to instance calls, static one-off calls, empty-body (`Void`) endpoints,
raw-body endpoints, and completion handlers (`Result<HelixResponse<Value>, HelixError>`).

Keep three details in mind when reading ``HelixRateLimit``:

- **Partial headers are tolerated.** Each field (`limit`, `remaining`, `resetAt`) is parsed
  independently. Missing, negative, overflowing, or malformed fields stay `nil` without failing
  an otherwise valid response. ``HelixResponseMetadata/rateLimit`` is `nil` only when no valid
  rate-limit fields were present at all.
- **Observations are snapshots, not live gauges.** Concurrent responses can arrive out of order,
  so a response's `remaining` value reflects the server's state when that specific response was
  generated—not guaranteed current capacity.
- **Zero remaining does not block the next call.** Seeing `remaining == 0` on a 2xx response
  does not pause subsequent requests in the library.

### Handling HTTP 429 Responses

Every HTTP 429 response throws ``HelixError/rateLimited(_:)`` carrying a
``HelixRateLimitError``, even if Twitch's error body is empty or non-JSON:

```swift
do {
  let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
  print(response.value)
} catch HelixError.rateLimited(let error) {
  print(error.message ?? "Twitch rate-limited the request.")
  if let resetAt = error.metadata.rateLimit?.resetAt {
    print("Bucket reset header:", resetAt)
  }
  // Decide whether to back off, notify the user, or abort.
}
```

``HelixRateLimitError`` exposes:

- ``HelixRateLimitError/metadata`` — the HTTP 429 status and any valid rate-limit headers.
- ``HelixRateLimitError/name`` and ``HelixRateLimitError/message`` — Twitch's error strings,
  when the response body decoded as JSON.
- ``HelixRateLimitError/responseData`` — the raw, unmodified response bytes.

> Warning: Some Helix endpoints enforce their own per-channel or per-user cooldowns separate
> from the general token bucket. An HTTP 429 does not always mean the general bucket is empty,
> so ``HelixRateLimit/resetAt`` is not a universal "safe to retry at" timestamp.

### Interaction with EventSub and Managed Chat

- **EventSub** creates and deletes WebSocket subscriptions using the same Helix pipeline
  without special rate-limit queuing. If creating a subscription hits HTTP 429,
  ``TwitchClient/eventStream(for:bufferingPolicy:)`` or
  ``TwitchClient/eventListener(for:callback:)`` throws ``HelixError/rateLimited(_:)``.
- **Managed chat** applies its own *process-local* send pacing (separate from Helix token
  buckets) to help interactive chat senders stay within Twitch's per-channel and 30-second
  chatter limits. See <doc:ManagedChat> for details on ``ChatSendingPolicy`` and
  ``ChatSendEligibility``.

For Twitch's server-side bucket rules and point costs, see the
[Twitch API Rate Limits guide](https://dev.twitch.tv/docs/api/guide/#twitch-rate-limits).

## See Also

- <doc:Helix>
- <doc:ManagedChat>
- ``HelixResponse``
- ``HelixResponseMetadata``
- ``HelixRateLimit``
- ``HelixRateLimitError``
