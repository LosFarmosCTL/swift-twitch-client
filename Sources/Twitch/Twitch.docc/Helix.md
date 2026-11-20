# Making Helix API Requests

Execute typed Twitch Helix endpoints with async/await or callbacks, inspect response metadata,
and handle API errors cleanly.

## Overview

Twitch's Helix REST API is modeled around two types:

- ``HelixEndpoint``, a lightweight value describing an HTTP method, path, authentication rule,
  encoded parameters, and response decoding logic.
- ``HelixResponse``, which wraps the endpoint's decoded ``HelixResponse/value`` together with
  ``HelixResponseMetadata`` (HTTP status code and parsed rate-limit headers).

Constructing a ``HelixEndpoint`` through its static factory methods performs no network I/O.
Network work happens only when you pass the endpoint to ``TwitchClient``.

### Running Requests with async/await

Call ``TwitchClient/helix(for:)`` on a ``TwitchClient`` instance:

```swift
let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
let users = response.value

for user in users {
  print(user.id, user.displayName)
}
```

Endpoints that return no body (such as deleting a message or updating a setting) return
`HelixResponse<Void>`, marked `@discardableResult` so you can ignore the return value when you
do not need its HTTP metadata:

```swift
try await twitch.helix(for: .deleteChatMessage(in: broadcasterID, messageID: messageID))
```

### One-Off Static Requests and Callbacks

If you do not need a long-lived ``TwitchClient`` (for example, in a CLI tool or stateless
request handler), call the static ``TwitchClient/helix(for:credentials:urlSession:diagnostics:)``
overload directly:

```swift
let response = try await TwitchClient.helix(
  for: .getUsers(userLogins: ["twitchdev"]),
  credentials: credentials
)
```

For callback-based codebases, use ``TwitchClient/helixTask(for:completionHandler:)`` (or its
static counterpart). It returns a ``TwitchCancellable`` handle:

```swift
let request = twitch.helixTask(for: .getUsers(userLogins: ["twitchdev"])) { result in
  switch result {
  case .success(let response):
    print("Fetched \(response.value.count) user(s)")
  case .failure(.cancelled):
    break
  case .failure(let error):
    print("Request failed:", error)
  }
}

// Later, if needed:
request.cancel()
```

> Important: Completion handlers run in an unstructured task with no main-actor guarantee.
> Dropping the returned ``TwitchCancellable`` does **not** cancel the request—you must call
> ``TwitchCancellable/cancel()`` explicitly.

### Pagination

Paginated endpoints return a response struct containing the page's items plus an optional
`cursor` string. Pass that cursor into the next request's `after` (or `before`) parameter until
Twitch stops returning a cursor:

```swift
var cursor: String?
var allStreams: [Stream] = []

repeat {
  let page = try await twitch.helix(
    for: .getStreams(gameIDs: ["509658"], limit: 100, after: cursor)
  ).value
  allStreams.append(contentsOf: page.streams)
  cursor = page.cursor
} while cursor != nil
```

If an endpoint returns valid page data alongside a malformed optional `pagination` object, the
library reports a `.pagination` diagnostic (see <doc:Diagnostics>) and returns the decoded
items with a `nil` cursor instead of discarding the page.

### Checking Operation-Level Results

A 2xx HTTP response from Twitch does not always mean the requested action took effect. Several
endpoints return an explicit delivery or status verdict inside the decoded payload—for example,
``HelixEndpoint/sendChatMessage(in:message:replyTo:isSourceOnly:pin:senderID:)`` returns a
``ChatMessageResponse`` whose ``ChatMessageResponse/isSent`` property can be `false` even on
HTTP 200:

```swift
let result = try await twitch.helix(
  for: .sendChatMessage(in: broadcasterID, message: "Hello chat!")
).value

if !result.isSent, let reason = result.dropReason {
  print("Message dropped (\(reason.code)): \(reason.message)")
}
```

### Handling Errors

Async Helix calls throw ``HelixError`` for request failures and Swift's `CancellationError`
when the calling task is cancelled (callback APIs deliver ``HelixError/cancelled`` instead).

```swift
do {
  let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
  print(response.value)
} catch is CancellationError {
  // Task was cancelled.
} catch HelixError.authenticationError(let authError) {
  // Local pre-flight check failed before any HTTP call was sent.
  print("Incompatible credentials or parameters:", authError)
} catch HelixError.rateLimited(let rateLimitError) {
  // HTTP 429 — see RateLimiting for retry guidance.
  print("Rate limited until:", rateLimitError.metadata.rateLimit?.resetAt as Any)
} catch HelixError.twitchError(let name, let status, let message) {
  // Twitch returned a structured 4xx/5xx error.
  print("Twitch error \(status) (\(name)): \(message)")
} catch HelixError.parsingResponseFailed(let failure) {
  // Response JSON didn't match the expected schema — see Diagnostics.
  print("Decoding failed at \(failure.details.pathDescription)")
} catch HelixError.networkError(let underlying) {
  print("Transport failure:", underlying)
}
```

Each Helix call makes exactly one HTTP attempt—the library never sleeps, queues, or retries
automatically. See <doc:RateLimiting> for inspecting bucket headers and designing retry logic,
and <doc:Diagnostics> for monitoring decoding failures across your app.

## See Also

- <doc:RateLimiting>
- <doc:Authentication>
- <doc:Diagnostics>
- ``HelixEndpoint``
- ``HelixResponse``
- ``HelixError``
