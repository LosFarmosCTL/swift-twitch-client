# Authentication

Choose the right credential kind for your app, validate tokens, and rotate credentials safely.

## Overview

Every request through ``TwitchClient`` is authorized by a ``TwitchCredentials`` value. The
library never fetches, stores, or refreshes OAuth tokens on your behalf—how you obtain a token
depends on whether you are building a desktop/mobile client, a bot, a backend service, or a
Twitch Extension. See Twitch's [authentication overview](https://dev.twitch.tv/docs/authentication/)
for choosing an OAuth flow.

A single ``TwitchClient`` holds one ``TwitchCredentials`` value at a time. If your application
needs to make both user-authorized and app-authorized requests concurrently, create two
separate ``TwitchClient`` instances.

### Choosing a Credential Kind

``TwitchCredentials/Kind`` supports three authentication modes:

| Kind | Created with | Helix | EventSub WebSockets | Managed Chat |
| --- | --- | --- | --- | --- |
| **User OAuth** | ``TwitchCredentials/init(accessToken:clientID:userID:userLogin:scopes:)`` or ``ValidatedAccessToken/credentials(accessToken:)`` | User & shared endpoints | Supported | Full read & write (with required scopes) |
| **App OAuth** | ``TwitchCredentials/app(accessToken:clientID:)`` | App & shared endpoints (supply acting user IDs explicitly) | Not supported (use Helix for webhooks/conduits) | Not supported for writes or authenticated reads |
| **Extension JWT** | ``TwitchCredentials/extensionJWT(token:clientID:)`` | JWT-only extension endpoints | Not supported | Not supported |

> Note: Managed chat also supports an **anonymous IRC reader**
> (`ChatConfiguration(reader: .irc(.anonymous))`). Joining a pre-resolved ``ChatChannel`` with
> an anonymous reader requires no OAuth token or Helix call. See <doc:ManagedChat>.

### Validate OAuth Tokens at Startup

The easiest and safest way to build ``TwitchCredentials`` from a user or app OAuth token is to
validate it with ``TwitchClient/validateAccessToken(accessToken:urlSession:)``:

```swift
let token = "<user or app OAuth token>"
let validated = try await TwitchClient.validateAccessToken(accessToken: token)

print("Client ID:", validated.clientID)
print("Expires in:", validated.expiresIn ?? -1, "seconds")

let credentials = validated.credentials(accessToken: token)
let twitch = TwitchClient(credentials: credentials)
```

Pass the exact same token string to ``ValidatedAccessToken/credentials(accessToken:)`` that you
validated. Using the validated result gives you two extra benefits over manual construction:

1. **Verified identity** — ``ValidatedAccessToken/kind`` is automatically `.user(UserIdentity)`
   for user tokens or `.app` for app tokens, with ``TwitchCredentials/user`` populated when
   present.
2. **Known scopes** — ``TwitchCredentials/scopes`` is populated from Twitch's response. Optional
   scope-gated features in managed chat (such as ``ChatConfiguration/moderationEnrichment`` and
   ``ChatConfiguration/prefillModeratedChannels``) only activate when the required scopes are
   positively known to be present.

> Important: Twitch requires applications with long-lived OAuth sessions to validate tokens on
> startup and hourly thereafter (see [Validating Requests](https://dev.twitch.tv/docs/authentication/validate-tokens/)).
> The library provides the validation call, while your app owns the timer and refresh flow.

### Construct Credentials Directly

If you already know the client ID and account identity (for instance, from cached session
metadata), construct ``TwitchCredentials`` directly without making a network request:

```swift
let userCredentials = TwitchCredentials(
  accessToken: "<user token>",
  clientID: "<client ID>",
  userID: "<user ID>",
  userLogin: "<login>",
  scopes: ["chat:read", "user:write:chat"]
)

let appCredentials = TwitchCredentials.app(
  accessToken: "<app token>",
  clientID: "<client ID>"
)
```

Initialization strips any leading `oauth:` prefix from `accessToken` and normalizes `userLogin`
to lowercase without contacting Twitch. Leaving `scopes` as `nil` means "unknown", not "empty":
Helix and EventSub still send requests normally and let Twitch enforce scopes, while optional
managed chat enrichments stay dormant until scopes are supplied.

> Warning: App access tokens are obtained through the OAuth Client Credentials flow using your
> confidential client secret. Keep that secret on a trusted backend—never ship a client secret
> inside a client app. App tokens cannot be refreshed; request a new one when expired.

### App Tokens and Acting User IDs

With a user token, endpoints that act on behalf of a user default to ``TwitchCredentials/userID``.
App tokens carry no user identity (`credentials.user == nil`), so you must supply the acting
user ID or lookup target explicitly:

```swift
let app = TwitchClient(credentials: appCredentials)

// Public lookups need at least one ID or login with an app token:
let users = try await app.helix(for: .getUsers(userLogins: ["twitchdev"])).value

// Actions on behalf of a bot/user need an explicit senderID:
let sent = try await app.helix(for: .sendChatMessage(
  in: "141981764",
  message: "Hello from an app token!",
  senderID: botUserID
)).value
```

Before sending any Helix request, ``TwitchClient`` checks both the credential kind and
token-dependent parameter constraints locally, throwing ``HelixError/authenticationError(_:)``
wrapping ``TwitchAuthenticationError`` if something does not match:

- Passing an app token to a user-only endpoint throws ``TwitchAuthenticationError/userAccessTokenRequired``.
- Omitting a required user ID with an app token throws ``TwitchAuthenticationError/missingUserID(parameter:)``.
- Passing a user ID that differs from a user token's own account throws ``TwitchAuthenticationError/userIDMismatch(parameter:)``.
- Using token-specific parameters improperly—such as setting `isSourceOnly` on
  ``HelixEndpoint/sendChatMessage(in:message:replyTo:isSourceOnly:pin:senderID:)`` with a user
  token, or combining `pin: true` with `replyTo` or `isSourceOnly`—throws
  ``TwitchAuthenticationError/invalidParameter(parameter:reason:)``.

An app token never bypasses user consent: Twitch still checks prior user grants, channel roles,
and account eligibility on the server.

### Extension Backend Service (EBS) JWTs

Certain Twitch Extension Helix endpoints require an externally signed JWT rather than an OAuth
access token:

```swift
let jwtCredentials = TwitchCredentials.extensionJWT(
  token: "<externally signed JWT>",
  clientID: "<extension client ID>"
)
let extensionClient = TwitchClient(credentials: jwtCredentials)
```

Your backend is responsible for signing the JWT with the claims required by the endpoint (see
Twitch's [Extension JWT schema](https://dev.twitch.tv/docs/extensions/reference/#jwt-schema)).
The client transmits it as a `Bearer` token without validating or signing claims.

> Important: Do **not** pass an EBS JWT to ``TwitchClient/validateAccessToken(accessToken:urlSession:)``,
> EventSub, or IRC. OAuth-only Helix endpoints reject JWT credentials with
> ``TwitchAuthenticationError/oauthAccessTokenRequired``, and JWT-only endpoints reject OAuth
> credentials with ``TwitchAuthenticationError/extensionJWTRequired``.

### Rotating or Switching Credentials

When your app refreshes an expired token or signs into a different Twitch account, call
``TwitchClient/switchCredentials(to:chatBehavior:)`` on the existing client:

```swift
await twitch.switchCredentials(
  to: refreshedCredentials,
  chatBehavior: .preserveChannels
)
```

Here is what happens across each subsystem during a switch:

- **Helix**: Subsequent calls immediately use the new credentials; requests already in flight
  finish with the credentials they started with.
- **EventSub**: Existing WebSocket sessions tear down, active observers finish normally, and
  upstream subscription deletion uses the credentials that originally created each subscription.
  Re-create your EventSub streams after the switch if you want to continue observing under the
  new token.
- **Managed chat**: With ``ChatCredentialSwitchBehavior/preserveChannels`` (the default),
  desired channels are kept—an anonymous IRC reader stays connected, while account-bound IRC
  and EventSub transports restart with the new credentials. Pass
  ``ChatCredentialSwitchBehavior/partChannels`` to leave all joined channels instead. Pending
  readiness waits from before the switch fail with ``ChatError/credentialsChanged``.

## See Also

- <doc:Helix>
- <doc:EventSub>
- <doc:ManagedChat>
- ``TwitchCredentials``
- ``ValidatedAccessToken``
- ``TwitchAuthenticationError``
