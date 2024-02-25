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
let twitch = TwitchClient(with: credentials)

// Completion Handlers

twitch.requestTask(for: .doSomething(param1: "forsen")) { result, error in
}

// Async/Await
let result = try await twitch.request(endpoint: .doSomething(param1: "forsen"))

// Combine
twitch.requestPublisher(for: .doSomething(param1: "forsen")).sink(
  receiveCompletion: { error in

  },
  receiveValue: { result in

  })
```

### Chat (IRC)

```swift
let twitch = TwitchClient(with: credentials)

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

// WIP

```
