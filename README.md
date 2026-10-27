# swift-twitch-client

[![CI](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml/badge.svg)](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml)

> [!WARNING]
> The developement of this library is still in progress and I am not commited to a stable release yet.
>
> While the overall API surface likely won't change, breaking changes are absolutely possible without notice!

Swift native client providing fully type- and threadsafe access to the Twitch API, IRC and EventSub in a convenient way.

## Features

- [x] Works on all Apple platforms, as well as Linux ([with caveats due to libcurl](#linux-support))
- [x] Compatible with Swift 6s new strict concurrency model
- [x] Access all documented, non-retired Helix endpoints using async/await or callbacks
- [x] Access IRC chat _and_ EventSub using event listeners, `AsyncStream` or Combine
- [x] Handles all annoying plumbing for you
  - [x] Connection pooling for IRC & EventSub
  - [x] Automatic welcome message and keepalive handling
  - [x] Automatic reconnection for IRC & EventSub
  - [x] IRC parsing (huge shoutout to [TwitchIRC](https://github.com/MahdiBM/TwitchIRC))
  - [x] JSON encoding/decoding
  - [x] Typed request parameters
  - [x] Typed response models
  - [x] Typed error models
  - [x] Typed event models
- [x] Support for user and app access tokens in Helix
- [ ] **Planned**: Automatic Helix Rate Limit handling

## Installation

Requires Swift 6.4 or later, using Swift 6 language mode. Supported deployment targets are macOS 13, iOS 16, tvOS 16, and watchOS 9 or later.

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/LosFarmosCTL/swift-twitch-client.git", branch: "main")
```

## Documentation

See the [API reference](https://docs.chatless.app/swift-twitch-client/) for the available Helix endpoints, EventSub subscriptions and events, and IRC APIs. The examples below cover getting started with each.

## Usage

### Creating credentials

See the [Twitch docs](https://dev.twitch.tv/docs/authentication/) on how to obtain a Client ID and OAuth token. The flow you choose depends on your application, e.g. a mobile chat client can prompt a user to log in through a browser, while a server-side bot might use a different flow.

You can validate a user or app access token and use the result to create a `TwitchClient`:

```swift
let token = "<token>"
let validatedToken = try await TwitchClient.validateAccessToken(accessToken: token)
let credentials = validatedToken.credentials(accessToken: token)
let twitch = TwitchClient(credentials: credentials)
```

You can also create credentials directly:

```swift
let credentials = TwitchCredentials(
  accessToken: "<user token>",
  clientID: "<client ID>",
  userID: "<user ID>",
  userLogin: "<login>"
)

let appCredentials = TwitchCredentials.app(
  accessToken: "<app token>", clientID: "<client ID>"
)
```

See the [authentication guide](Sources/Twitch/Twitch.docc/Authentication.md) for token requirements, Extension JWTs, and credential management.

### Helix

```swift
// Using async/await

let result = try await twitch.helix(for: .someEndpoint(param1: "forsen"))

// Using completion Handlers

let request = twitch.helixTask(
  for: .someEndpoint(param1: "forsen", param2: ["foo", "bar"])
) { result in
}

// returns a TwitchCancellable that can be used to cancel the request
request.cancel()
```

App tokens use the same Helix API. For endpoints that act on a user, supply that user's ID explicitly:

```swift
let app = TwitchClient(credentials: appCredentials)
let sent = try await app.helix(for: .sendChatMessage(
  in: "1234", message: "Hello chat!", senderID: "5678"
))
```

### EventSub

EventSub streams, listeners and publishers use WebSockets and require user credentials.

```swift
let twitch = TwitchClient(credentials: credentials)

// Using AsyncStream

let stream = try await twitch.eventStream(for: .channelFollow(
  broadcasterID: "1234",
  moderatorID: "5678"
))

for try await event in stream {
  print(event)
}

// Using callbacks

try await twitch.eventListener(for: .streamOnline(broadcasterID: "1234")) { result in
  switch result {
  case .event(let event): print(event)
  case .failure(let error): print(error)
  case .finished: break
  }
}

// Using Combine

let publisher = try await twitch.eventPublisher(for: .userUpdate(userID: "1234"))

publisher.sink(
  receiveCompletion: { error in
    // handle error
  },
  receiveValue: { event in
    // handle event
  })
```

### Chat (IRC)

Authenticated IRC requires a user access token. IRC has its own session lifetime, separate from Helix and EventSub. The factory captures the current credentials;
later `TwitchClient.switchCredentials` calls do not update an existing IRC session.

```swift
let irc = await twitch.makeIRCClient(mode: .receiveOnly)
let messages = await irc.messageStream()
let states = await irc.stateUpdates()

try await irc.setDesiredChannels(["forsen", "twitchdev"])

// Start consumers before connecting so healthy sockets can deliver during startup.
let messageTask = Task {
  for try await message in messages {
    if case .privateMessage(let chat) = message {
      print(chat.message)
    }
  }
}

let stateTask = Task {
  for await state in states {
    print(state.status, state.channels)
    // state.recoveries includes the affected channels, reason, retry attempt,
    // and scheduled retry time (nil while establishing the replacement socket).
    // state.globalUserState retains the latest USERSTATE information.
  }
}

try await irc.connect()

// replace the full set of channels at once, or JOIN/PART individually
try await irc.setDesiredChannels(["xqc", "twitchdev"])
try await irc.requestPart(from: "xqc")
try await irc.requestJoin(to: "forsen")

await irc.shutdown()
try await messageTask.value
await stateTask.value
```

IRC is accessible via listeners and combine publishers as well:

```swift
let irc = await twitch.makeIRCClient()

let listener = await irc.messageListener { event in
  switch event {
  case .message(let message): print(message)
  case .finished: print("IRC session ended")
  case .failure(let error): print(error)
  }
}

let cancellable = await irc.messagePublisher().sink(
  receiveCompletion: { completion in print(completion) },
  receiveValue: { message in print(message) })

try await irc.setDesiredChannels(["forsen"])
try await irc.connect()
try await irc.sendMessage("Hello chat!", to: "forsen")
await irc.shutdown()
```

## One-off requests using static methods

You can also use the static methods on `TwitchClient` to make one-off requests to the Twitch API by passing in `TwitchCredentials` to the `helix()` method directly:

```swift
let result = try await TwitchClient.helix(for: .someEndpoint(param1: "forsen"), credentials: credentials)
```

## Linux support

This library will compile completely fine on Linux, minus the Combine support of course and normal HTTP requests to Helix will work as expected.

However, `FoundationNetworking` uses libcurl for all networking on Linux and WebSocket support has only been included by default since version `8.11.0`, which is to my knowledge pretty rare to find on server distros. If an older version of libcurl without support is being used, connecting to a webSocket will crash with a `fatalError`! For some more information you can see swiftlang/swift-corelibs-foundation#4730
