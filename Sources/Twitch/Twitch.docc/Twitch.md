# ``Twitch``

Access Twitch Helix, EventSub, and IRC with typed, sendable Swift APIs.

## Overview

Use Helix to query profiles, streams, and channel data or perform actions such as
updating a channel. Use EventSub to react to live activity, including stream starts,
follows, and reward redemptions. Use IRC to receive and send chat messages through
an independently managed session.

Create a ``TwitchClient`` with ``TwitchCredentials`` for Helix and EventSub. The
examples below run in an asynchronous, throwing context, with the token and account
identity supplied by your app.

```swift
import Twitch

let credentials = TwitchCredentials(
  accessToken: token,
  clientID: clientID,
  userID: userID,
  userLogin: login
)
let twitch = TwitchClient(credentials: credentials)
```

Credentials must have the scopes and account roles required by the selected
operation. The library does not obtain or refresh OAuth tokens.

### Query and update data with Helix

Choose a typed ``HelixEndpoint`` factory, then execute its request through the client.
For example, look up a Twitch user's profile:

```swift
let response = try await twitch.helix(for: .getUsers(userIDs: [userID]))
let users = response.value

for user in users {
  print(user.displayName)
}
```

Factories describe requests without performing network I/O. The result type depends
on the endpoint. Request failures throw ``HelixError``, and cancellation throws
`CancellationError`. Helix also supports completion handlers. Each Helix response includes HTTP and rate-limit metadata.
Requests do not wait or retry automatically; see <doc:RateLimiting>.

Some extension endpoints require an Extension Backend Service (EBS) JWT instead of a
Twitch OAuth access token. Use `TwitchCredentials.extensionJWT(token:clientID:)` with
an externally signed JWT and the extension’s client ID. The client sends the JWT as
a Bearer token; it does not sign JWTs. Do not pass an EBS JWT to `validateAccessToken`,
which validates OAuth tokens. JWT credentials cannot authorize OAuth-only endpoints,
IRC, or EventSub.

### React to live activity with EventSub

Choose an ``EventSubSubscription`` factory and consume its typed notifications.
This example observes when a broadcaster starts streaming:

```swift
let notifications = try await twitch.eventStream(
  for: .streamOnline(broadcasterID: userID)
)

for try await notification in notifications {
  print("\(notification.event.broadcasterDisplayName) started streaming")
}
```

The client receives notifications over WebSockets. Matching subscription descriptions
share one Twitch subscription. Cancelling the consuming task removes its observer.
When the last observer leaves, the client schedules unsubscription.
Connection failures and revocations finish the stream with an ``EventSubError``.
Call ``TwitchClient/resetEventSub()`` to close all EventSub connections and finish
their consumers. Callbacks and Combine publishers are also available where supported.

Streams, callbacks, and publishers deliver an ``EventSubNotification`` with the
typed event, its notification and subscription IDs, and `sentAt`, the time Twitch
sent the notification.

### Inspect decoding failures

Use ``TwitchClient/decodingDiagnostics()`` or configure a callback with
``TwitchDiagnostics``. Both deliver the same structured reports from Helix and
EventSub, including Helix requests made by managed chat and EventSub.

```swift
let reports = await twitch.decodingDiagnostics()
for await report in reports {
  print(report.stage, report.details.pathDescription)
}
```

Register before starting the operations you want to observe. Each stream buffers
the newest 64 pending reports and survives credential changes and EventSub resets.

```swift
let twitch = TwitchClient(
  credentials: credentials,
  diagnostics: .init(onDecodingFailure: { diagnostic in
    print(diagnostic.source, diagnostic.stage, diagnostic.details.pathDescription)
  })
)
```

The callback runs synchronously and may be called concurrently, with no main-actor
guarantee. Static Helix requests also accept `diagnostics:`. Reports omit payload
bodies and original Swift errors. Coding paths and EventSub identifiers can contain
user data. Malformed EventSub messages are skipped, and a Helix result with malformed
optional pagination remains usable without a cursor.

Helix requests still throw on parsing failures. Both parsing error cases carry a
``HelixDecodingFailure`` with the original error, structured details, and response data.
If you previously extracted the raw body directly from either case, use
`failure.responseData`. HTTP 429 still produces ``HelixError/rateLimited(_:)`` even
when its body cannot be decoded.

```swift
do {
  _ = try await twitch.helix(for: .getUsers())
} catch HelixError.parsingResponseFailed(let failure) {
  print(failure.details.kind, failure.details.pathDescription)
  let original = failure.underlyingError as? DecodingError
}
```

Coding paths use decoder keys and array indices. Key decoding strategies can change
the spelling of keys from the original payload.

### Manage chat from TwitchClient

Choose a reader and writer with ``ChatConfiguration``. Register a message stream before
joining to receive the first normalized events, then call `join` to await channel readiness.
Use `requestJoin` to start setup without waiting for readiness. Cancelling an observer or
readiness wait leaves the channel joined. Call `part` to withdraw membership and
``TwitchClient/shutdownChat()`` to close the managed transports and finish the observers.

``TwitchClient/chatStateUpdates()`` yields the latest membership, connection, and send
state. Managed sends apply process-local sender limits, channel pacing, and known
restrictions. Raw `helix(for:)` sends and `sendIRC` remain available for direct requests.
Moderation enrichment is opt-in and uses observed roles plus known token scopes.

Credential switches preserve desired channels by default. Pass `chatBehavior: .partChannels`
to clear them. A preserved anonymous IRC reader stays connected, and account-bound
transports restart with the new credentials.

For transport-specific access, use the raw IRC stream, listener, or publisher on
``TwitchClient``. Each delivery identifies the read or write connection that received it.
Raw sends use the configured IRC writer and apply IRC wire validation.

## Topics

### Client and authentication

- <doc:Authentication>
- ``TwitchClient``
- ``TwitchCredentials``
- ``TwitchDiagnostics``
- ``TwitchDecodingDiagnostic``
- ``TwitchDecodingFailureDetails``
- ``ValidatedAccessToken``
- ``AccessTokenValidationError``
- ``TwitchAuthenticationError``
- ``TwitchCancellable``

### Helix requests

- <doc:RateLimiting>
- ``HelixEndpoint``
- ``HelixError``
- ``HelixDecodingFailure``
- ``HelixResponse``
- ``HelixResponseMetadata``
- ``HelixRateLimit``
- ``HelixRateLimitError``
- ``ChatSettingsUpdate``

### EventSub notifications

- ``Event``
- ``EventSubSubscription``
- ``EventSubNotification``
- ``EventSubListenerEvent``
- ``EventSubError``
- ``EventSubRevocation``

### Managed chat

- ``ChatConfiguration``
- ``ChatChannel``
- ``ChatEvent``
- ``ChatState``
- ``ChatSendingPolicy``
- ``ChatSendEligibility``
- ``IRCMessage``
- ``IRCListenerEvent``

- ``IRCState``
- ``IRCRecovery``
- ``IRCChannelStatus``
- ``IRCChannelFailure``
- ``IRCError``
