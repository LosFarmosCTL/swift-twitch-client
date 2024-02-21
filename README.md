# swift-twitch-client

[![CI](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml/badge.svg)](https://github.com/LosFarmosCTL/swift-twitch-client/actions/workflows/main.yml)

WIP - Swift native client to access various 3rd party twitch elements like the API and Chat.

> [!CAUTION]
> The developement of this library is still very much in progress, APIs may be incomplete or change without any notice!
>
> I do not recommend to use this in any projects until I finalized the design.

*This is the current idea for how the usage might look in the end (not final, if I find something better I will just switch):*

### Helix

```swift
// Completion Handlers
helix.requestTask(for: .doSomething(param1: "forsen")) { result, error in
}

// Async/Await
let result = try await helix.request(endpoint: .doSomething(param1: "forsen"))

// Combine
helix.requestPublisher(for: .doSomething(param1: "forsen")).sink(
  receiveCompletion: { error in

  },
  receiveValue: { result in

  })
```

### Chat (IRC)

```swift
// Using AsyncStream (more options, e.g. Combine planned as well)
let client = ChatClient(.anonymous)

let messageStream = try await client.connect()

try await client.join(to: "channel")

for try await message in messageStream {
  if case .privateMessage(let privMsg) = message {
    try await client.send("Received message: \(privMsg.message)", in: "forsen")
  }
}
```

### EventSub

```swift

// WIP

```
