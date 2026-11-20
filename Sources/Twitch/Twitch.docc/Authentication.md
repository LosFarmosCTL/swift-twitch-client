# Authentication

Choose credentials for the Twitch API or transport your application uses.

## Overview

``TwitchCredentials`` represents a user OAuth access token, an app OAuth access token,
or an externally signed Extension Backend Service (EBS) JWT. A ``TwitchClient`` uses
one set of credentials for its Helix requests and direct EventSub subscriptions.
Applications that need both user and app operations can create separate clients.

The library accepts existing tokens. Obtaining, storing, and replacing them remains
the application's responsibility. See the [Twitch authentication documentation](
https://dev.twitch.tv/docs/authentication/) for the available OAuth flows.

### Validate OAuth tokens

``TwitchClient/validateAccessToken(accessToken:)`` validates either OAuth access-token
kind and returns a ``ValidatedAccessToken``:

```swift
let token = "<user or app access token>"
let validated = try await TwitchClient.validateAccessToken(accessToken: token)
let credentials = validated.credentials(accessToken: token)
let twitch = TwitchClient(credentials: credentials)
```

Supply the same token to `credentials(accessToken:)` that you submitted for validation.
The result's `kind` is `.user(UserIdentity)` or `.app`. Validation also provides the
client ID, scopes, and remaining lifetime in seconds (`expiresIn`). The lifetime is
`nil` if Twitch omits it or reports zero. App tokens have no user ID or login.

Applications maintaining OAuth sessions must validate their tokens at startup and
hourly, as described in [Twitch's validation requirements](
https://dev.twitch.tv/docs/authentication/validate-tokens/). The library provides the
validation request without scheduling repeated validation.

### Create credentials directly

When the token's application and identity are already known, create credentials
without a validation request:

```swift
let userCredentials = TwitchCredentials(
  accessToken: "<user token>",
  clientID: "<client ID>",
  userID: "<user ID>",
  userLogin: "<login>"
)

let appCredentials = TwitchCredentials.app(
  accessToken: "<app token>", clientID: "<client ID>"
)
```

The client ID must match the application that issued the token. Initialization removes
a leading `oauth:` prefix and lowercases user logins; it does not contact Twitch.

App tokens are obtained through the server-side client credentials flow, which requires
a confidential client secret. Keep that secret on a backend rather than embedding it
in a distributed application. App tokens cannot be refreshed; obtain a replacement
through the client credentials flow when necessary. See [getting tokens](
https://dev.twitch.tv/docs/authentication/getting-tokens-oauth/#client-credentials-grant-flow)
and [token renewal](https://dev.twitch.tv/docs/authentication/refresh-tokens/).

### Account identity

User credentials expose the authorized account through `credentials.user`. Its `id`
and `login` are available together:

```swift
if let account = credentials.user {
  print(account.id, account.login)
}
```

`user`, `userID`, and `userLogin` are optional because app tokens and Extension JWT
credentials do not carry an OAuth user identity. Token validation exposes the same
optional account information for user and app tokens.

### Supply acting user IDs for app requests

When you send a chat message with a user token, TwitchClient uses that account as
the sender by default. An app token doesn't identify a user, so you supply
`senderID`. In both cases, `channelID` is the destination, not the sender:

```swift
let app = TwitchClient(credentials: appCredentials)
let sent = try await app.helix(for: .sendChatMessage(
  in: channelID, message: "Hello chat!", senderID: botID
))

let user = TwitchClient(credentials: userCredentials)
let userSent = try await user.helix(for: .sendChatMessage(
  in: channelID, message: "Hello chat!"
))
```

Public lookups such as `getUsers` also need an explicit target with an app token:

```swift
let response = try await app.helix(for: .getUsers(userLogins: ["twitchdev"]))
let users = response.value
```

Factories document their token and scope requirements. Twitch checks scopes, prior
user grants, roles, and account eligibility. An app token does not bypass user consent,
and its validation scopes do not enumerate all earlier user grants to the application.

The client rejects incompatible credentials before sending a request and reports
the reason as a ``TwitchAuthenticationError``.

Some parameters depend on the token kind: `isSourceOnly` on chat messages and
announcements is app-only. Drops entitlement `userID` filters must match the token's
user ID when using a user token. Pinning a chat message cannot be combined with a
reply or `isSourceOnly`. The endpoint reference
describes these rules alongside the additional grant requirements.

### Use Extension JWTs

Some extension endpoints require an EBS JWT rather than an OAuth access token:

```swift
let credentials = TwitchCredentials.extensionJWT(
  token: "<externally signed JWT>", clientID: "<extension client ID>"
)
let extensions = TwitchClient(credentials: credentials)
```

The caller signs the JWT with the claims required by the endpoint. The library sends
it as a Bearer token and does not sign or validate its claims. JWT-only endpoints reject
user and app OAuth credentials, and OAuth-only endpoints reject JWT credentials.

Do not submit an EBS JWT to OAuth token validation or use it to authenticate IRC or
EventSub. See the [Twitch Extension reference](
https://dev.twitch.tv/docs/extensions/reference/#jwt-schema) for JWT requirements.

### EventSub and IRC requirements

The high-level EventSub stream, listener, and publisher methods manage direct WebSocket
subscriptions and require user credentials. App credentials can create raw webhook or
conduit subscriptions through Helix and call conduit management endpoints. The library
does not provide webhook receivers or manage conduit shard reception. Event-specific
consent requirements apply to those subscriptions.

Managed chat uses a user access token with `user:read:chat` for direct EventSub reads,
`chat:read` for authenticated IRC reads, `user:write:chat` for Helix writes, and
`chat:edit` for IRC writes. Managed writes require user credentials for either writer.
The raw Helix Send Chat Message endpoint also supports app tokens with Twitch's
required prior user grants.

Choose an anonymous reader explicitly with `ChatConfiguration(reader: .irc(.anonymous))`.
Where Twitch permits anonymous IRC access, a join with an already resolved `ChatChannel`
does not need an OAuth request. Resolving an unknown channel first uses Helix and
requires credentials.

### Credential and session lifetimes

`switchCredentials(to:chatBehavior:)` updates the credentials used by subsequent Helix
requests. In-flight requests retain their captured credentials. EventSub observers finish
when teardown begins, and subscription cleanup uses the credentials that created each
subscription.

Managed chat preserves desired channels by default. The anonymous IRC reader can stay
connected while account-bound transports restart. Pass `chatBehavior: .partChannels`
to clear managed membership during the switch.
