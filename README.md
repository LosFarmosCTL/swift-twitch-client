# swift-twitch-client

[![CI](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml/badge.svg)](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml)

Swift native client to access various 3rd party twitch elements like the API and Chat.

> [!CAUTION]
> The developement of this library is still very much in progress, APIs may be incomplete or change without any notice!
>
> I do not recommend to use this in any projects until I've finalized the design.

__This is the *current* idea for how the usage might look in the end (not at all final, if I find something that feels better right now I will just change it):__

### Helix

```swift
let twitch = TwitchClient(authentication: credentials)

// Completion Handlers

twitch.helixTask(for: .doSomething(param1: "forsen")) { result, error in
}

// Async/Await
let result = try await twitch.helix(endpoint: .doSomething(param1: "forsen"))

// Combine
twitch.helixPublisher(for: .doSomething(param1: "forsen")).sink(
  receiveCompletion: { error in

  },
  receiveValue: { result in

  })
```

### Chat (IRC)

```swift
let twitch = TwitchClient(authentication: credentials)

let irc = try await twitch.ircClient(.authenticated)

try await irc.join(to: "forsen")
try await irc.part(from: "forsen")

// Using callbacks

irc.listener { result in
  switch result {
  case .success(let message): print(message)
  case .failure(let error): print(error)
  }
}

// Using AsyncStream

let stream = irc.stream()
for try await message in stream {
  if case .privateMessage(let privMsg) = message {
    try await client.send("Received message: \(privMsg.message)", in: "forsen")
  }
}

// Using Combine

let publisher = irc.publisher()

irc.publisher().sink(
  receiveCompletion: {
    // handle error
  },
  receiveValue: {
    // handle msg
  })

```

### EventSub

```swift
let twitch = TwitchClient(authentication: credentials)

// Using callbacks

try await twitch.eventListener(on: .streamOnline(broadcasterID: "1234")) { result in
  switch result {
  case .event(let event): print(event)
  case .failure(let error): print(error)
  case .finished: break
  }
}

// Using AsyncStream

let stream = try await twitch.eventStream(for: .channelFollow(
  broadcasterID: "1234",
  moderatorID: "5678"
))

for try await event in stream {
  print(event)
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
