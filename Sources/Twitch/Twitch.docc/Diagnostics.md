# Debugging Decoding Failures

Capture structured decoding reports from Helix and EventSub to detect Twitch schema drift
safely without leaking raw payload data into telemetry.

## Overview

Twitch occasionally adds enum values, alters optional fields, or changes payload shapes across
Helix and EventSub. `Twitch` gives you two complementary ways to observe decoding failures:

1. **Client-wide structured diagnostics** (``TwitchClient/decodingDiagnostics()`` and
   ``TwitchDiagnostics``) — privacy-conscious reports emitted for every Helix and EventSub
   decoding failure, including internal Helix calls made by EventSub and managed chat.
2. **Thrown Helix failures** (``HelixDecodingFailure``) — attached to
   ``HelixError/parsingResponseFailed(_:)`` and
   ``HelixError/parsingErrorFailed(status:failure:)`` when you need the original Swift
   `DecodingError` and raw response bytes locally.

### Stream Diagnostics from a Client

Register ``TwitchClient/decodingDiagnostics()`` before starting the requests or subscriptions
you want to monitor:

```swift
let diagnosticsTask = Task {
  let reports = await twitch.decodingDiagnostics()
  for await report in reports {
    print(
      "[\(report.source).\(report.stage)]",
      "\(report.details.kind) at \(report.details.pathDescription)",
      "(\(report.payloadByteCount) bytes)"
    )
  }
}
```

Each call creates an independent stream buffering the **64 newest** pending reports (dropping
the oldest if your consumer falls behind). Diagnostic streams survive
``TwitchClient/switchCredentials(to:chatBehavior:)`` and ``TwitchClient/resetEventSub()``, and
finish automatically when the client is deallocated. Cancel the consuming `Task` when you want
to unregister early.

### Use a Synchronous Callback (Including Static Helix Calls)

If you prefer a callback or want diagnostics on one-off static
``TwitchClient/helix(for:credentials:urlSession:diagnostics:)`` requests, pass a
``TwitchDiagnostics`` value:

```swift
let diagnostics = TwitchDiagnostics { report in
  print(
    report.source,
    report.stage,
    report.requestPath ?? report.eventSubMetadata?.subscriptionType ?? "-",
    report.details.pathDescription
  )
}

let twitch = TwitchClient(credentials: credentials, diagnostics: diagnostics)
```

> Important: The ``TwitchDiagnostics`` callback runs **synchronously** at the site of the
> decoding failure with no main-actor guarantee, and may be invoked concurrently from multiple
> Helix tasks or EventSub WebSocket connections. Keep it lightweight and synchronize any shared
> state.

### Reading a Diagnostic Report

Every ``TwitchDecodingDiagnostic`` identifies:

- ``TwitchDecodingDiagnostic/source`` — `.helix` or `.eventSub`.
- ``TwitchDecodingDiagnostic/stage`` — where decoding failed:
  - `.response` — a 2xx Helix payload failed to decode (the Helix call still throws).
  - `.errorResponse` — a non-2xx Helix error body could not be decoded.
  - `.pagination` — an optional Helix `pagination` object was malformed; the response data
    remained usable with a `nil` cursor.
  - `.eventSubMessage` — an EventSub WebSocket envelope could not be decoded; the frame was
    skipped and the connection stayed open.
  - `.eventSubPayload` — a notification's typed event payload could not be decoded; the frame
    was skipped and the subscription remained active.
- ``TwitchDecodingDiagnostic/details`` (``TwitchDecodingFailureDetails``) — the
  ``TwitchDecodingFailureDetails/Kind`` (`keyNotFound`, `typeMismatch`, `valueNotFound`,
  `dataCorrupted`, or `other`), the ``TwitchDecodingFailureDetails/codingPath`` array, a
  formatted ``TwitchDecodingFailureDetails/pathDescription`` (such as
  `data[0].broadcasterType`, or `$` at the root), and the expected Swift type name when
  available.
- **Context fields** — ``TwitchDecodingDiagnostic/payloadByteCount``, Helix
  `requestMethod` / `requestPath` / `metadata`, or EventSub
  ``TwitchDecodingDiagnostic/EventSubMetadata`` (`connectionID`, `messageID`, `messageType`,
  `sentAt`, `subscriptionID`, `subscriptionType`, `subscriptionVersion`, `channelID`).

> Note: Because the client's `JSONDecoder` uses `convertFromSnakeCase`, keys in `codingPath`
> and `pathDescription` reflect Swift decoder keys rather than Twitch's raw snake_case wire
> spelling.

> Warning: ``TwitchDecodingDiagnostic`` deliberately omits raw response bodies and original
> Swift errors so private payload contents are not accidentally logged. However, coding paths
> and ``TwitchDecodingDiagnostic/EventSubMetadata`` fields (such as channel and subscription
> IDs) can still contain user-identifying metadata—treat them accordingly in external telemetry.

### Inspecting Thrown Helix Decoding Errors Locally

Helix parsing failures still throw ``HelixError/parsingResponseFailed(_:)`` or
``HelixError/parsingErrorFailed(status:failure:)`` carrying a ``HelixDecodingFailure``. Use it
when debugging locally or capturing a reproduction fixture:

```swift
do {
  _ = try await twitch.helix(for: .getUsers(userLogins: ["twitchdev"]))
} catch HelixError.parsingResponseFailed(let failure) {
  print("Kind:", failure.details.kind)
  print("Path:", failure.details.pathDescription)
  print("Underlying error:", failure.underlyingError)
  print("Raw response size:", failure.responseData.count)
}
```

Note that HTTP 429 always throws ``HelixError/rateLimited(_:)`` even when its error body is
empty or unparseable, while still reporting an `.errorResponse` diagnostic if a non-empty body
fails to decode.

## See Also

- <doc:Helix>
- <doc:EventSub>
- ``TwitchDiagnostics``
- ``TwitchDecodingDiagnostic``
- ``TwitchDecodingFailureDetails``
- ``HelixDecodingFailure``
