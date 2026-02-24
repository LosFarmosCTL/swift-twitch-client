# Agent Guide for swift-twitch-client

This repository is a Swift Package Manager library for a Twitch client.
Use this guide as the default operating manual for agentic code changes.

**Project layout**

- SwiftPM package definition: `Package.swift`
- Library target: `Twitch`
- Test target: `TwitchTests`
- Sources: `Sources/Twitch/...`
- Tests: `Tests/TwitchTests/...`

**General orientation (start here)**

- Primary entry point is the `TwitchClient` actor in `Sources/Twitch/TwitchClient.swift`
- `TwitchClient` owns credentials, a `NetworkSession`, and shared JSON encoder/decoder
- JSON config: snake_case keys + ISO8601 with fractional seconds (both encode/decode)
- CodingKeys: decoder uses convertFromSnakeCase, so map to camelCase strings (e.g., `broadcasterID = "broadcasterId"`) when overriding; do not map to snake_case literals
- The project is split into three feature areas under `Sources/Twitch`: Helix, EventSub, IRC
- Each area is exposed through `TwitchClient` extensions (`TwitchClient+Helix.swift`, etc.)
- Shared infrastructure (credentials, networking, JSON config) lives at the `TwitchClient` level
- Helix (REST) lives in `Sources/Twitch/Helix`
- Endpoints are `HelixEndpoint` factories that build requests and map `HelixResponse`
- Helix flow: endpoint -> URLRequest -> `NetworkSession.data` -> decode -> response mapping
- Helix errors are modeled in `HelixError` (network vs Twitch vs parsing)
- EventSub (WebSocket) lives in `Sources/Twitch/EventSub`
- Message decoding is in `EventSub/message` with payload models for welcome/reconnect/etc.
- Event models live in `EventSub/Events` and are routed through `EventSubHandler`
- Subscription factories live in `EventSub/Subscriptions` and feed the EventSub client
- EventSub flow: socket message -> payload -> event -> handler -> callback/stream
- Connection lifecycle is coordinated by `EventSubClient` + `EventSubConnection`
- IRC chat lives in `Sources/Twitch/IRC` with connection pooling + message handlers
- IRC flow: connection pool -> message stream -> handlers -> callback/stream
- All networking uses `NetworkSession` to support URLSession + WebSockets
- Tests mirror sources: Helix in `Tests/TwitchTests/API`, EventSub in `Tests/TwitchTests/EventSub`
- Shared test helpers live in `Tests/TwitchTests/Shared`, mock JSON in `MockResources`

**Build commands**

- Build all targets: `swift build -v`
- Build a specific target: `swift build --target Twitch`

**Test commands**

- Run all tests: `swift test`
- List tests: `swift test --list-tests`
- Run a single test: `swift test --filter "EventSubWhisperTests/testWhisperReceivedEvent"`
- Run a single test suite: `swift test --filter "EventSubWhisperTests"`
- Run by substring match: `swift test --filter "Whisper"`

**Lint commands**

- SwiftLint (strict): `swiftlint --strict`
- SwiftLint config: `.swiftlint.yml` with local overrides in EventSub folders

**Formatting rules (from .swift-format)**

- Indentation: 2 spaces
- Max line length: 90
- Ordered imports required
- No semicolons
- No block comments; use // or ///
- One variable declaration per line
- Use shorthand type names (e.g., `[String]` not `Array<String>`)
- Prefer file-scoped declarations to be `private` by default
- Identifiers must be ASCII
- Use triple slash for doc comments when needed

**Code style guidelines**

- Follow the local style of each directory; EventSub has its own SwiftLint overrides
- Keep public API minimal and explicit; default to `internal` or `private`
- Prefer `actor` for shared mutable state and concurrency boundaries
- Use `Sendable` on types crossing concurrency domains
- Use async/await APIs as the primary surface, then add callbacks/Combine wrappers
- Avoid force unwraps and force casts unless there is a compelling reason; justify with a comment only if non-obvious
- Do not add TODO comments unless necessary; the linter disables the TODO rule but keep noise low
- Keep methods small and focused; extract helpers inside the same file when possible

**Imports**

- Standard order is required by `OrderedImports`
- Use conditional imports for FoundationNetworking and Combine when needed
- Avoid unused imports

**Naming**

- Types: UpperCamelCase, keep under 60 chars where possible
- Identifiers: lowerCamelCase, keep under 60 chars where possible
- Use descriptive event names; the EventSub folder uses explicit, domain-driven naming
- Favor clarity over abbreviations in public API

**Types and API design**

- Prefer structs and enums for data models
- Keep decoding types `Decodable` only when encoding is not needed
- Use generic endpoints to enforce response typing

**Networking**

- Use `NetworkSession` abstraction for URLSession and WebSocket tasks
- When building requests, apply auth headers from `TwitchCredentials`
- Encode request bodies with JSONEncoder configured for `convertToSnakeCase`
- Decode responses with JSONDecoder configured for `convertFromSnakeCase` and ISO8601 with fractional seconds

**Concurrency**

- Actors manage shared mutable state (`TwitchClient`, `EventSubClient`, `EventSubConnection`)
- Use `@Sendable` closures for async callbacks
- Be explicit about actor isolation boundaries when passing methods as handlers

**Testing guidelines**

- New tests must use Swift Testing (`import Testing`); do not add new XCTest tests
- XCTest remains only for legacy Helix tests until they are migrated
- Use `@testable import Twitch` in tests
- Use `Mocker` with `MockingURLProtocol` for HTTP tests
- Keep mock JSON under `Tests/TwitchTests/**/MockResources`
- Use helper utilities in `Tests/TwitchTests/Shared`
- For Swift Testing, prefer `#expect`/`#require` and `@Suite`/`@Test`

**Resources**

- Test resources are declared in `Package.swift` under `TwitchTests`
- When adding new mock JSON, ensure the directory is included under resources

**Platform and toolchain**

- Package supports macOS 13+, iOS 16+, tvOS 16+, watchOS 9+
- CI uses Swift 6.2 and Swiftly; local toolchain should match Swift 6.2

**When in doubt**

- Match the style of nearby files before introducing new patterns
- Keep changes minimal and focused on the requested feature or fix
