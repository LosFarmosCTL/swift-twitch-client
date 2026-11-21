# Managing Twitch Chat

Join channels, consume normalized chat events, send paced messages, and drop down to raw IRC
when you need full wire control.

## Overview

Twitch offers multiple ways to read and write chat—IRC WebSockets, EventSub chat topics, and
the Helix `Send Chat Message` endpoint—each with different scopes, metadata, and delivery
semantics. Managed chat on ``TwitchClient`` unifies them behind one coherent lifecycle while
letting you pick the exact transports your app needs.

### Configure Transports

Configure managed chat once when creating ``TwitchClient`` using ``ChatConfiguration``:

```swift
let twitch = TwitchClient(
  credentials: credentials,
  chat: ChatConfiguration(
    reader: .irc(.authenticated),
    writer: .helix,
    sending: .interactive,
    moderationEnrichment: false,
    prefillModeratedChannels: false
  )
)
```

Your choice of ``ChatConfiguration/Reader`` and ``ChatConfiguration/Writer`` determines both
capabilities and required OAuth scopes:

| Transport | Configuration | Credential & Scope Requirements | Notes |
| --- | --- | --- | --- |
| **Authenticated IRC reader** (default) | `.irc(.authenticated)` | User token with `chat:read` | Connection-pooled; provides IRC badges, `USERSTATE`, `ROOMSTATE`, emote ranges, and `CLEARCHAT`. |
| **Anonymous IRC reader** | `.irc(.anonymous)` | None when joining a resolved ``ChatChannel`` | Read-only `justinfan` session; stays connected across credential switches when channels are preserved. |
| **EventSub reader** | `.eventSub` | User token with `user:read:chat` | Subscribes to 6 chat topics per channel and fetches initial room settings via Helix; provides structured message fragments. |
| **Helix writer** (default) | `.helix` | User token with `user:write:chat` | Returns confirmed ``ChatSendOutcome/accepted(messageID:)`` or throws ``ChatSendError/rejected(code:message:)``. |
| **IRC writer** | `.irc` | User token with `chat:edit` | Dedicated write socket; supports `clientNonce` and raw ``TwitchClient/sendIRC(_:)``, but writes are not delivery receipts. |

> Tip: Passing an already-resolved ``ChatChannel`` (`ChatChannel(id:login:)`) avoids an extra
> Helix user lookup. With `.irc(.anonymous)`, passing a ``ChatChannel`` lets you read public
> chat with no OAuth token at all; joining by login or ID still resolves the user via Helix.

### Register Observers, Then Join Channels

Always register ``TwitchClient/messageStream(bufferingPolicy:)`` (and optionally
``TwitchClient/chatStateUpdates()``) **before** calling `join` so you do not miss initial
room-settings snapshots or early messages:

```swift
let events = await twitch.messageStream()
let states = await twitch.chatStateUpdates()

// Start consuming events in a background task
let readerTask = Task {
  for await event in events {
    switch event.payload {
    case .message(let message):
      print("[\(event.channel.login)] \(message.author.displayName ?? "?"): \(message.text)")
    case .notification(let notice):
      print("[\(event.channel.login)] \(notice.kind): \(notice.systemMessage ?? "")")
    case .settingsChanged(let settings):
      print("[\(event.channel.login)] slowMode=\(String(describing: settings.slowMode))")
    case .messageDeleted(let deletion):
      print("Deleted message \(deletion.messageID)")
    case .messagesCleared(let user):
      print("Cleared messages for \(user?.login ?? "entire room")")
    case .moderation(let moderation):
      print("Moderation action:", moderation.action)
    case .notice(let code, let text):
      print("IRC notice (\(code ?? "none")): \(text)")
    case .membershipEnded(let reason):
      print("Left \(event.channel.login):", reason)
    }
  }
}

// Join and wait until the channel's reader is ready
try await twitch.join(to: .login("twitchdev"))
```

Use `join(to:)` (with a resolved ``ChatChannel`` or a ``ChatChannelTarget`` such as `.login(_:)`
or `.id(_:)`) when you want to await channel readiness, or `requestJoin(to:)` to register desired
membership and start connecting in the background while tracking progress in
``TwitchClient/chatStateUpdates()``.

Key membership rules to keep in mind:

- **Cancelling a readiness wait does not part the channel.** If the task awaiting `join` is
  cancelled, membership stays active; call `part(from:)` explicitly with a ``ChatChannel`` or
  ``ChatChannelTarget`` to leave.
- **Cancelling an observer leaves membership intact.** Closing `messageStream()` only stops
  your consumer.
- **Shutting down is permanent.** Call ``TwitchClient/shutdownChat()`` when your app is done
  with chat to close all managed transports and finish every chat and raw IRC stream. Helix
  and direct EventSub APIs on the same ``TwitchClient`` continue working.

### Transport-Specific Details on Messages and Notices

``ChatMessage`` and ``ChatNotification`` normalize common fields without inventing data that
only one transport supplies (for example, ``ChatMessage/isFirstMessage`` is populated only on
IRC, whereas ``ChatMessage/isIntroduction`` is populated only on EventSub). Whenever you need
transport-specific fields—such as IRC emote character ranges vs. EventSub typed message
fragments—switch on ``ChatMessage/details`` or ``ChatNotification/details``:

```swift
switch message.details {
case .irc(let privmsg):
  print("IRC emotes:", privmsg.emotes)
case .eventSub(let event):
  print("EventSub fragments:", event.message.fragments)
}
```

### Sending Messages and Local Pacing

Send messages with `sendMessage(_:in:replyTo:clientNonce:waitingForChannelCooldown:)` using
either a resolved ``ChatChannel`` or a ``ChatChannelTarget``:

```swift
do {
  let outcome = try await twitch.sendMessage(
    "Hello chat!",
    in: .login("twitchdev"),
    waitingForChannelCooldown: .seconds(2)
  )

  switch outcome {
  case .accepted(let messageID):
    print("Accepted by Helix:", messageID)
  case .written(let nonce):
    print("Written to IRC wire (nonce: \(nonce ?? "none"))")
  }
} catch ChatSendError.rejected(let code, let message) {
  print("Rejected (\(code ?? "none")): \(message)")
} catch ChatSendError.refused(let eligibility) {
  print("Refused locally:", eligibility)
} catch HelixError.rateLimited(let error) {
  print("Rate limited by Twitch:", error)
}
```

Understand three important sending behaviors before shipping:

1. **Helix acceptance vs. IRC wire writes.** A Helix writer returns
   ``ChatSendOutcome/accepted(messageID:)`` when Twitch accepts the message and throws
   ``ChatSendError/rejected(code:message:)`` when Twitch drops it (`isSent == false`). An IRC
   writer returns ``ChatSendOutcome/written(clientNonce:)`` as soon as the command is written
   to the WebSocket—this is **not** a delivery receipt. If Twitch rejects the message later
   (for example, slow mode or AutoMod), a ``ChatEvent/Payload/notice(code:message:)`` arrives
   asynchronously on the chat stream and is not tied back to the original send call.
2. **Process-local send pacing.** With ``ChatSendingPolicy/interactive`` (the default), the
   client tracks managed send attempts per sender account in-process and checks:
   - **Account sliding window**: 20 messages / 30 seconds for ordinary chatters, or 100 / 30
     seconds when the sender is a known broadcaster, moderator, or VIP in the channel.
   - **Per-channel cooldown**: at least ``ChatSendingPolicy/ordinaryChannelInterval`` (default
     1.1 seconds, minimum 1,001 ms) or the channel's observed ``ChatRoomSettings/slowMode``,
     whichever is longer, for ordinary chatters.
   - **Observed restrictions**: bans and active timeouts observed in the channel are surfaced in
     ``TwitchClient/sendEligibility(in:)`` and ``ChatState/sendEligibility`` for UI state,
     without locally blocking `sendMessage` so Twitch remains authoritative.
   Passing `waitingForChannelCooldown` opts into a bounded wait *only* for
   ``ChatSendEligibility/channelCooldown(until:)``; account-window exhaustion always throws
   ``ChatSendError/refused(_:)`` immediately. Use ``ChatSendingPolicy/unpaced`` to bypass
   local refusals while still validating messages.
3. **Never retried automatically.** Ambiguous network writes are never retried to prevent
   duplicate chat messages. Check ``TwitchClient/sendEligibility(in:)`` or
   ``ChatState/sendEligibility`` to drive disabled states or countdowns in your UI.

> Note: Local pacing is a process-local guardrail, not Twitch's authoritative server-side
> rate limiter. Another device or client logged into the same account shares Twitch's real
> limits without appearing in this process's ledger.

### Privileges and Opt-In Moderation Enrichment

Managed chat automatically learns sender roles (``ChatPrivilege``) from channel ownership
(`channel.id == credentials.userID`), IRC `USERSTATE` and message badges, and moderation
events. You can supplement this in two ways:

- Set `prefillModeratedChannels: true` on ``ChatConfiguration`` (requires
  `user:read:moderated_channels` in ``TwitchCredentials/scopes``) to discover moderated
  channels once via Helix.
- Call ``TwitchClient/setChatPrivilege(_:in:)`` to install or clear an explicit role override
  for a channel.

For moderation visibility:

- **Without enrichment**, the chat reader reports observable room changes: single deletions
  emit `.messageDeleted`, room/user clears emit `.messagesCleared`, and targeted IRC
  `CLEARCHAT` commands also emit `.moderation` (ban or timeout with duration). EventSub's
  `channel.chat.clear_user_messages` does not indicate whether a clear was a ban or timeout,
  so it does not synthesize a `.moderation` event on its own.
- **With `moderationEnrichment: true`**, managed chat subscribes to `channel.moderate` v2 over
  EventSub for channels where the user has known moderator/broadcaster status **and**
  ``TwitchCredentials/scopes`` positively includes all required moderation read/manage scope
  pairs (obtain credentials via ``TwitchClient/validateAccessToken(accessToken:urlSession:)`` or pass
  `scopes:` explicitly). Enrichment adds richer `.moderation` events (including moderator
  identity, reasons, unbans, untimeouts, and modern actions) to the same stream without
  replacing reader events—so a single deletion can emit both `.messageDeleted` and
  `.moderation`, and an IRC reader plus enrichment can report the same ban/timeout from both
  sources.

> Note: AutoMod hold and review notifications are intentionally excluded from managed chat;
> observe them directly with ``TwitchClient/eventStream(for:bufferingPolicy:)``.

### Credential Switching and Raw IRC Access

When calling ``TwitchClient/switchCredentials(to:chatBehavior:)``, desired channels are
preserved by default (``ChatCredentialSwitchBehavior/preserveChannels``): an anonymous IRC
reader stays connected uninterrupted, while account-bound transports restart cleanly with the
new credentials. Pass ``ChatCredentialSwitchBehavior/partChannels`` to clear membership
instead.

If you need raw `TwitchIRC` frames or custom IRC commands alongside managed chat (add
`import TwitchIRC` in files where you spell `TwitchIRC` types such as `OutgoingMessage`
explicitly):

- Observe raw incoming frames from the configured IRC reader and/or writer with
  ``TwitchClient/ircMessageStream(bufferingPolicy:)``,
  ``TwitchClient/ircMessageListener(_:)``, or ``TwitchClient/ircMessagePublisher()``. Each
  ``IRCMessage`` identifies its ``IRCRecovery/Role`` (`.read` or `.write`).
- Send validated raw `OutgoingMessage` commands through ``TwitchClient/sendIRC(_:)`` when
  `writer: .irc` is configured (bypasses managed send pacing while still preventing wire
  injection).
- Inspect per-transport connection, channel, and recovery diagnostics on
  ``ChatState/ircReader`` and ``ChatState/ircWriter`` (``IRCState`` and ``IRCRecovery``).

## See Also

- <doc:Authentication>
- <doc:EventSub>
- <doc:Helix>
- ``ChatConfiguration``
- ``ChatEvent``
- ``ChatState``
- ``ChatSendingPolicy``
- ``IRCMessage``
