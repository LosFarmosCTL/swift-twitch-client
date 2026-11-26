# Changelog

<!-- Add changes under Unreleased. Move them into a new X.Y.Z section when ready.
Successful CI on main prepares a draft release; publishing remains manual. -->

## Unreleased

## 1.1.1

### Fixes

- Fix EventSub charity campaign broadcaster keys and chat charity amount precision keys.
- Correct the suspicious-user update status, add the Mythic Hype Train type, and correct the documented AutoMod settings scope.

## 1.1.0

### Features

- Normalized `ChatMessage.isAction` and ordered `ChatMessage.emotes` across IRC and EventSub. Emote ranges use Unicode scalar offsets into `ChatMessage.text`, which omits CTCP framing for EventSub `/me` messages.
- Signed-out `TwitchClient(chat:urlSession:diagnostics:)` initializer and `clearCredentials(chatBehavior:)` for public Helix and anonymous IRC usage.

### Fixes

- Verify IRC `room-id` tags against active memberships, evict stale channel aliases on rename, and ignore late reader traffic after parting.
- Fix races when retrying/rejoining failed IRC channels, withdrawing in-flight ID joins by login, and reusing failed IRC writers.
- Report `ChatState.writer` as `.unavailable` and fail `sendMessage(in:)` before channel lookup when using non-user credentials.

## 1.0.0

First stable release of `swift-twitch-client`, targeting Swift 6.4+ in Swift 6 language mode on macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+, and Linux.

### Highlights

- **Helix API**: Full typed coverage of Twitch Helix endpoints via async/await (`helix(for:)`) and callbacks (`helixTask(for:completionHandler:)`), one-off static requests, per-response HTTP/rate-limit metadata, and typed HTTP 429 (`HelixError.rateLimited`) handling.
- **Authentication**: Support for user OAuth tokens, app OAuth tokens, Extension Backend Service JWTs, OAuth token validation (`validateAccessToken`), and live credential rotation (`switchCredentials(to:chatBehavior:)`).
- **EventSub**: Pooled WebSocket client supporting `AsyncThrowingStream`, callbacks, and Combine publishers with automatic welcome handshakes, keepalives, seamless `session_reconnect` handoffs, shared upstream subscriptions, and custom topic decoding.
- **Managed Chat & Raw IRC**: Unified managed chat supporting authenticated IRC, anonymous IRC, and EventSub readers; Helix and IRC writers; process-local send pacing; opt-in EventSub moderation enrichment; and direct raw IRC stream/callback/Combine/send access powered by `TwitchIRC` 2.1.
- **Diagnostics & SemVer-safe models**: Opt-in structured decoding diagnostics (`TwitchDiagnostics` / `decodingDiagnostics()`), open `RawRepresentable` wire-decoded value types that preserve unfamiliar Twitch values, explicit public initializers across public models, and localized error descriptions via `Localizable.xcstrings` on Apple platforms.

### Installation

```swift
.package(url: "https://github.com/LosFarmosCTL/swift-twitch-client.git", from: "1.0.0")
```

Add the product to your target:

```swift
.product(name: "Twitch", package: "swift-twitch-client")
```
