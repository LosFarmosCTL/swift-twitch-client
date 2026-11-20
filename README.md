# swift-twitch-client

[![CI](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml/badge.svg)](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml)

> [!WARNING]
> Development of this library is still in progress and there is not yet a stable release.
>
> While the overall API surface likely won't change, breaking changes are possible without notice.

A native Swift client providing type-safe, Swift 6 concurrency-safe access to Twitch chat (managed chat and raw IRC), EventSub, and the Helix API.

## Features

- [x] Runs on Apple platforms (macOS, iOS, tvOS, watchOS) and Linux ([with caveats](#platform-notes))
- [x] Built for Swift 6 strict concurrency (`Sendable` models, actor-isolated client)
- [x] Managed chat with selectable readers (authenticated IRC, anonymous IRC, EventSub) and writers (Helix, IRC), plus raw IRC access
- [x] Real-time EventSub over WebSockets via `AsyncThrowingStream`, callbacks, or Combine
- [x] Full typed coverage of the Twitch Helix API via async/await or callbacks
- [x] Handles connection plumbing automatically
  - [x] Connection pooling for IRC and EventSub WebSockets
  - [x] Welcome handshakes, keepalives, and automatic reconnection / handoffs
  - [x] IRC parsing via [TwitchIRC](https://github.com/LosFarmosCTL/TwitchIRC)
  - [x] Typed request parameters, response models, events, and errors
- [x] User OAuth tokens, app OAuth tokens, and Extension Backend Service JWTs
- [x] Per-response Helix rate-limit metadata, typed HTTP 429 errors, and structured decoding diagnostics

## Installation

Requires Swift 6.4 or later in Swift 6 language mode. Supported Apple deployment targets are macOS 13, iOS 16, tvOS 16, and watchOS 9 or later.

Add the dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/LosFarmosCTL/swift-twitch-client.git", branch: "main")
```

## Documentation

Browse the full [API reference and concept guides](https://docs.chatless.app/swift-twitch-client/) (built from [`Sources/Twitch/Twitch.docc`](Sources/Twitch/Twitch.docc/Twitch.md)) for deep dives into:

- [Authentication](Sources/Twitch/Twitch.docc/Authentication.md) — user/app tokens, Extension JWTs, scopes, and credential switching
- [Helix](Sources/Twitch/Twitch.docc/Helix.md) & [Rate Limiting](Sources/Twitch/Twitch.docc/RateLimiting.md) — endpoints, pagination, metadata, and HTTP 429 handling
- [EventSub](Sources/Twitch/Twitch.docc/EventSub.md) — WebSocket pooling, streams/callbacks/Combine, and custom topics
- [Managed Chat](Sources/Twitch/Twitch.docc/ManagedChat.md) — transport selection, local send pacing, moderation enrichment, and raw IRC
- [Diagnostics](Sources/Twitch/Twitch.docc/Diagnostics.md) — structured decoding-failure reports

## Quick Start

### 1. Create a client

Obtain a Client ID and OAuth token using the flow that fits your app (see [Twitch Authentication](https://dev.twitch.tv/docs/authentication/)). Validate the token to build `TwitchCredentials` with its verified identity and scopes, then create a `TwitchClient`:

```swift
import Twitch

let token = "<user OAuth token>"
let validated = try await TwitchClient.validateAccessToken(accessToken: token)
let credentials = validated.credentials(accessToken: token)

let twitch = TwitchClient(
  credentials: credentials,
  chat: .init(reader: .irc(.authenticated), writer: .helix)
)
```

If you already know the token's metadata (or are using an app token), construct `TwitchCredentials` directly without a validation request:

```swift
let userCredentials = TwitchCredentials(
  accessToken: "<user token>",
  clientID: "<client ID>",
  userID: "<user ID>",
  userLogin: "<login>"
)

let appCredentials = TwitchCredentials.app(
  accessToken: "<app token>",
  clientID: "<client ID>"
)
```

### 2. Query Twitch with Helix

Pass any typed `HelixEndpoint` factory to `helix(for:)`. Every response includes both the decoded `value` and HTTP/rate-limit `metadata`:

```swift
let response = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
guard let broadcaster = response.value.first else { return }

if let rateLimit = response.metadata.rateLimit {
  print("Remaining points:", rateLimit.remaining ?? -1)
}
```

Helix also supports completion handlers (`helixTask(for:completionHandler:)`), one-off static calls without a client instance, and app tokens (supply acting user IDs explicitly when using an app token):

```swift
// Callback-based request with explicit cancellation
let request = twitch.helixTask(for: .getUsers(userLogins: ["twitchdev"])) { result in
  // Handle Result<HelixResponse<[User]>, HelixError>
}
request.cancel()

// One-off static request without creating a TwitchClient
let oneOff = try await TwitchClient.helix(
  for: .getUsers(userLogins: ["twitchdev"]),
  credentials: appCredentials
)

// App-token action with an explicit acting user ID
let app = TwitchClient(credentials: appCredentials)
try await app.helix(for: .sendChatMessage(
  in: broadcaster.id,
  message: "Hello chat!",
  senderID: "<bot user ID>"
))
```

### 3. React to live events with EventSub

Subscribe to any `EventSubSubscription` over managed WebSockets (requires user credentials). Consume notifications with `AsyncThrowingStream`, callbacks, or Combine:

```swift
// AsyncThrowingStream
let events = try await twitch.eventStream(for: .streamOnline(broadcasterID: broadcaster.id))
for try await notification in events {
  print(notification.sentAt, "\(notification.event.broadcasterDisplayName) is live!")
}

// Callbacks (cancel explicitly via the returned TwitchCancellable)
let listener = try await twitch.eventListener(
  for: .streamOnline(broadcasterID: broadcaster.id)
) { delivery in
  switch delivery {
  case .event(let notification): print(notification.event)
  case .failure(let error): print(error)
  case .finished: break
  }
}

// Combine (Apple platforms)
let publisher = twitch.eventPublisher(for: .streamOnline(broadcasterID: broadcaster.id))
```

### 4. Join and send chat

Register `messageStream()` before joining so you receive initial events, then join and send messages through your configured reader and writer transports:

```swift
let messages = await twitch.messageStream()

try await twitch.join(login: "twitchdev")
try await twitch.sendMessage("Hello chat!", login: "twitchdev")

for await event in messages {
  if case .message(let message) = event.payload {
    print("\(message.author.displayName ?? "unknown"): \(message.text)")
  }
}
```

Use `ircMessageStream()`, `ircMessageListener(_:)`, `ircMessagePublisher()`, or `sendIRC(_:)` for direct access to the configured IRC transports.

## Platform notes

- **Linux**: Compiles cleanly (without Combine), and all Helix HTTP requests work normally. However, `FoundationNetworking` relies on `libcurl`, which only includes WebSocket support by default starting in `8.11.0`—rare on older server distros. Connecting an EventSub or IRC WebSocket against an older `libcurl` crashes with `fatalError` (see `swiftlang/swift-corelibs-foundation#4730`).
- **watchOS**: Helix over HTTPS works normally, but watchOS restricts direct WebSocket connections in ordinary apps (see [Apple TN3135](https://developer.apple.com/documentation/technotes/tn3135-low-level-networking-on-watchos)), so EventSub and IRC are not supported on Apple Watch.
