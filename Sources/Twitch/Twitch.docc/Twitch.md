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
let events = try await twitch.eventStream(
  for: .streamOnline(broadcasterID: userID)
)

for try await event in events {
  print("\(event.broadcasterDisplayName) started streaming")
}
```

The client creates the subscription and receives notifications over WebSockets.
Cancelling the consuming task terminates the stream and schedules unsubscription.
Connection failures and revocations finish the stream with an ``EventSubError``.
Call ``TwitchClient/resetEventSub()`` to close all EventSub connections and finish
their consumers. Callbacks and Combine publishers are also available where supported.

### Receive and send chat with IRC

Create a ``TwitchIRCClient``, register a message observer, and select channels before
connecting. This example joins the authenticated user's channel, sends a greeting,
and receives parsed IRC messages until the stream ends or its task is cancelled:

```swift
let irc = await twitch.makeIRCClient()
let messages = await irc.messageStream()
try await irc.setDesiredChannels([login])

do {
  try await irc.connect()
  try await irc.sendMessage("Hello chat!", to: login)

  for try await message in messages {
    print(message)
  }
} catch {
  await irc.shutdown()
  throw error
}

await irc.shutdown()
```

Observe ``TwitchIRCClient/stateUpdates()`` for connectivity, channel membership,
and recovery progress. Cancelling a message observer leaves the session running;
call ``TwitchIRCClient/shutdown()`` when the session is no longer needed.

IRC sessions capture credentials when created and have independent lifetimes.
Switching the parent client's credentials does not update an existing IRC session.
For a session that only receives messages, pass `mode: .receiveOnly` to
`makeIRCClient`. Anonymous reception is also available by constructing
`TwitchIRCClient(.anonymous, mode: .receiveOnly)` directly. IRC also supports
callbacks and Combine publishers where available.

## Topics

### Client and authentication

- <doc:Authentication>
- ``TwitchClient``
- ``TwitchCredentials``
- ``ValidatedAccessToken``
- ``AccessTokenValidationError``
- ``TwitchAuthenticationError``
- ``TwitchCancellable``

### Helix requests

- <doc:RateLimiting>
- ``HelixEndpoint``
- ``HelixError``
- ``HelixResponse``
- ``HelixResponseMetadata``
- ``HelixRateLimit``
- ``HelixRateLimitError``
- ``HelixEndpointResponseType``
- ``HelixEndpointResponseTypes``
- ``EmptyResponse``

### EventSub notifications

- ``Event``
- ``EventSubSubscription``
- ``EventSubListenerEvent``
- ``EventSubError``
- ``EventSubRevocation``

### IRC sessions

- ``TwitchIRCClient``
- ``IRCState``
- ``IRCRecovery``
- ``IRCChannelStatus``
- ``IRCChannelFailure``
- ``IRCListenerEvent``
- ``IRCError``
