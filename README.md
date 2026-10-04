# swift-twitch-client

[![CI](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml/badge.svg)](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml)

> [!WARNING]
> The developement of this library is still in progress and I am not commited to a stable release yet.
>
> While the overall API surface likely won't change, breaking changes are absolutely possible without notice!
>
> Documentation is also still a work in progress, while I do think this README should get you started, there are no DocC strings to document the actual code yet. Definitely on the Radar, but I haven't gotten to it so far.

Swift native client providing fully type- and threadsafe access to the Twitch API, IRC and EventSub in a convenient way.

## Features

- [x] Works on all Apple platforms, as well as Linux ([with caveats due to libcurl](#linux-support))
- [x] Compatible with Swift 6s new strict concurrency model
- [x] Access the full Helix API using async/await or callbacks
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
- [ ] **Planned**: Support for app access tokens in Helix
- [ ] **Planned**: Automatic Helix Rate Limit handling

## Installation

Add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/LosFarmosCTL/swift-twitch-client.git", branch: "main")
```

## Usage

### Creating credentials

See the Twitch docs on how to obtain the necessary ClientID and OAuth token, this will depend a lot on what you want to do and where you want to do it, e.g. a mobile chat client can prompt a user to login via a Browser, if you're building a Chatbot you might want to obtain your token via completely different flow - you'll have to decide what works best for you. You can validate a token using the static function `TwitchClient.validateToken` that will return a struct containing the ClientID, user ID, user login, scopes and expiry date of the given token:

```swift
let token = "<token>"

let validatedToken = try await TwitchClient.validateToken(token: token)
```

You can then create a `TwitchClient` using the `TwitchCredentials` struct:

```swift
let credentials = TwitchCredentials(
  oAuth: token,
  clientID: validatedToken.clientID,
  userID: validatedToken.userID,
  userLogin: validatedToken.userLogin
)

let twitch = TwitchClient(authentication: credentials)
```

Using the `TwitchClient` you can now access pretty much the full Twitch API surface:

### Helix

```swift
// Using async/await

let result = try await twitch.helix(endpoint: .someEndpoint(param1: "forsen"))

// Using completion Handlers

let request = twitch.helixTask(
  for: .someEndpoint(param1: "forsen", param2: ["foo", "bar"])
) { result in
}

// returns a TwitchCancellable that can be used to cancel the request
request.cancel()
```

### EventSub

```swift
let twitch = TwitchClient(authentication: credentials)

// Using AsyncStream

let stream = try await twitch.eventStream(for: .channelFollow(
  broadcasterID: "1234",
  moderatorID: "5678"
))

for try await event in stream {
  print(event)
}

// Using callbacks

try await twitch.eventListener(on: .streamOnline(broadcasterID: "1234")) { result in
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

IRC has its own session lifetime, separate from Helix and EventSub. The factory captures the current credentials;
later `TwitchClient.switchCredentials` calls do not update an existing IRC session.

```swift
let irc = await twitch.makeIRCClient(mode: .receiveOnly)
let messages = await irc.messages()
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

let listener = await irc.listener { event in
  switch event {
  case .message(let message): print(message)
  case .finished: print("IRC session ended")
  case .failure(let error): print(error)
  }
}

let cancellable = await irc.publisher().sink(
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
let result = try await TwitchClient.helix(endpoint: .someEndpoint(param1: "forsen"), authentication: credentials)
```

## Linux support

This library will compile completely fine on Linux, minus the Combine support of course and normal HTTP requests to Helix will work as expected.

However, `FoundationNetworking` uses libcurl for all networking on Linux and WebSocket support has only been included by default since version `8.11.0`, which is to my knowledge pretty rare to find on server distros. If an older version of libcurl without support is being used, connecting to a websocket will crash with a `fatalError`! For some more information you can see swiftlang/swift-corelibs-foundation#4730
