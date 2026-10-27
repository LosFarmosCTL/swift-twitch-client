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

User credentials carry an account identity that endpoint factories can use for defaults.
App credentials do not identify a user. For endpoints that act on an account, supply
the appropriate `senderID`, `moderatorID`, `broadcasterID`, `editorID`, or `userID`:

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
let users = try await app.helix(for: .getUsers(userLogins: ["twitchdev"]))
```

Factories document their token and scope requirements. Twitch checks scopes, prior
user grants, roles, and account eligibility. An app token does not bypass user consent,
and its validation scopes do not enumerate all earlier user grants to the application.

The client checks token-kind compatibility and token-dependent parameters before
sending requests. Violations throw ``HelixError/authenticationError(_:)`` containing a
``TwitchAuthenticationError``. Where Twitch requires an acting ID to match a user
token's account, an explicit ID is checked against that identity. Lookup targets can
identify other accounts when the endpoint permits it.

Some parameters depend on the token kind: `isSourceOnly` on chat messages and
announcements is app-only, as is `userID` filtering for Drops entitlements. Pinning a
chat message cannot be combined with a reply or `isSourceOnly`. The endpoint reference
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

Authenticated IRC requires user credentials. Connecting with app or JWT credentials
throws ``TwitchAuthenticationError/userAccessTokenRequired`` before a socket opens.
Anonymous reception is available explicitly:

```swift
let irc = TwitchIRCClient(.anonymous, mode: .receiveOnly)
```

### Credential and session lifetimes

``TwitchClient/switchCredentials(to:)`` changes the credentials used by subsequent Helix
requests and ends the previous EventSub context. In-flight Helix requests retain their
captured credentials. EventSub setup interrupted by a reset or switch is cancelled;
subscription cleanup uses the credentials captured when that subscription was created.

IRC sessions have independent lifetimes and capture credentials at creation. Switching
the parent client's credentials does not update an existing IRC session.

