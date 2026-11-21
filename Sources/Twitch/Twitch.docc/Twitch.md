# ``Twitch``

Access Twitch chat, EventSub, and the Helix API with typed, sendable Swift 6 APIs.

## Overview

`Twitch` wraps Twitch's three core interfaces behind a single actor, ``TwitchClient``:

- **Managed chat (and raw IRC)** — unified channel membership, normalized chat events, and
  paced sending over your choice of IRC (authenticated or anonymous) or EventSub for reading,
  and Helix or IRC for writing, while still exposing raw parsed IRC frames when you need them.
- **EventSub** — pooled WebSocket connections that deliver typed, real-time notifications via
  `AsyncThrowingStream`, callbacks, or Combine, handling welcomes, keepalives, reconnect
  handoffs, and shared subscriptions automatically.
- **Helix** — typed HTTP requests for querying and updating Twitch resources (profiles, streams,
  chat settings, clips, subscriptions, moderation, and more), with response metadata and
  explicit rate-limit visibility.

### Quick Tour

Start by validating an OAuth access token (or constructing ``TwitchCredentials`` directly) and
creating a ``TwitchClient``. The client opens no connections until you actually make a request,
subscribe to an event, or join a channel.

```swift
import Twitch

let token = "<user OAuth access token>"
let validated = try await TwitchClient.validateAccessToken(accessToken: token)
let credentials = validated.credentials(accessToken: token)

let twitch = TwitchClient(
  credentials: credentials,
  chat: .init(reader: .irc(.authenticated), writer: .helix)
)
```

From there, the same client drives Helix, EventSub, and chat together:

```swift
// 1. Look up a channel with Helix
let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
guard let broadcaster = response.value.first else { return }

// 2. React to live EventSub notifications in the background
let streamTask = Task {
  let events = try await twitch.eventStream(
    for: .streamOnline(broadcasterID: broadcaster.id)
  )
  for try await notification in events {
    print("\(notification.event.broadcasterDisplayName) is live!")
  }
}

// 3. Observe and participate in managed chat
let chatStream = await twitch.messageStream()
try await twitch.join(to: .login("twitchdev"))
try await twitch.sendMessage("Hello chat!", in: .login("twitchdev"))

for await event in chatStream {
  if case .message(let message) = event.payload {
    print("\(message.author.displayName ?? "unknown"): \(message.text)")
  }
}
```

> Note: Obtaining and refreshing OAuth tokens remains your application's responsibility. When
> you refresh or switch accounts, call ``TwitchClient/switchCredentials(to:chatBehavior:)`` to
> update the client cleanly without recreating it.

### Where to Go Next

Each subsystem has a dedicated guide covering architecture, gotchas, and production patterns:

- Start with <doc:Authentication> to understand user tokens, app tokens, Extension JWTs, scope
  requirements, and credential rotation.
- Read <doc:Helix> and <doc:RateLimiting> before making production API calls so you know how
  errors, pagination, and HTTP 429 responses behave.
- Read <doc:EventSub> to learn about subscription sharing, buffering policies, reconnection,
  and custom topics.
- Read <doc:ManagedChat> to choose reader/writer transports, handle send pacing and
  moderation enrichment, or access raw IRC.
- Read <doc:Diagnostics> to hook up structured decoding-failure reports for catching Twitch
  schema changes safely in production.

### Platform Support

`Twitch` targets Swift 6 language mode on macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+, and Linux.

> Important: **watchOS** restricts direct WebSocket connections in ordinary apps (see
> [Apple TN3135](https://developer.apple.com/documentation/technotes/tn3135-low-level-networking-on-watchos)).
> Use Helix over HTTPS on watchOS; direct EventSub and IRC connections are not supported.

> Warning: On **Linux**, `FoundationNetworking` relies on `libcurl`, which only enables
> WebSocket support by default starting in `libcurl 8.11.0`. Helix HTTP requests work on any
> supported Linux environment, while connecting EventSub or IRC WebSockets on older `libcurl`
> builds will trap at runtime. Combine publisher APIs are available only on Apple platforms.

## Topics

### Guides

- <doc:Authentication>
- <doc:Helix>
- <doc:RateLimiting>
- <doc:EventSub>
- <doc:ManagedChat>
- <doc:Diagnostics>

### Client and Authentication

- ``TwitchClient``
- ``TwitchCredentials``
- ``ValidatedAccessToken``
- ``AccessTokenValidationError``
- ``TwitchAuthenticationError``
- ``TwitchCancellable``

### Helix API

- ``HelixEndpoint``
- ``HelixResponse``
- ``HelixResponseMetadata``
- ``HelixRateLimit``
- ``HelixError``
- ``HelixRateLimitError``
- ``HelixDecodingFailure``

### EventSub

- ``EventSubSubscription``
- ``EventSubTransport``
- ``EventSubNotification``
- ``EventSubListenerEvent``
- ``Event``
- ``VoidEvent``
- ``EventSubError``
- ``EventSubRevocation``

### Managed Chat

- ``ChatConfiguration``
- ``ChatCredentialSwitchBehavior``
- ``ChatSendingPolicy``
- ``ChatChannel``
- ``ChatChannelTarget``
- ``ChatEvent``
- ``ChatMessage``
- ``ChatNotification``
- ``ChatMessageDeletion``
- ``ChatModeration``
- ``ChatUser``
- ``ChatBadge``
- ``ChatState``
- ``ChatChannelState``
- ``ChatComponentStatus``
- ``ChatRoomSettings``
- ``ChatPrivilege``
- ``ChatSendEligibility``
- ``ChatSendOutcome``
- ``ChatCredentialChange``
- ``ChatDeparture``
- ``ChatError``
- ``ChatSendError``

### Raw IRC

- ``IRCMessage``
- ``IRCListenerEvent``
- ``IRCState``
- ``IRCRecovery``
- ``IRCChannelStatus``
- ``IRCChannelFailure``
- ``IRCError``

### Diagnostics

- ``TwitchDiagnostics``
- ``TwitchDecodingDiagnostic``
- ``TwitchDecodingFailureDetails``
