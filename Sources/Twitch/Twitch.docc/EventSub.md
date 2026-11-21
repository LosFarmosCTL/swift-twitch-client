# Receiving Live Events with EventSub

Subscribe to real-time Twitch events over pooled WebSockets using async streams, callbacks,
or Combine.

## Overview

EventSub pushes live notifications from Twitch—stream online/offline transitions, follows,
subscriptions, Channel Points redemptions, chat activity, moderation actions, raids, and
more. ``TwitchClient`` manages the EventSub WebSocket lifecycle behind the scenes:

- **Lazy, pooled WebSockets** — no socket opens until you create your first subscription. Each
  WebSocket session holds up to 300 subscriptions, and new sessions open automatically up to
  Twitch's 3-session (900-subscription) WebSocket pool cap. Unused sessions close when their last
  subscription ends.
- **Keepalives and seamless reconnect handoffs** — Twitch's welcome handshake, keepalive
  deadlines, and `session_reconnect` URLs are handled automatically. During a reconnect
  handoff, the old socket drains pending frames while the replacement connects so active
  streams stay uninterrupted.
- **Shared upstream subscriptions** — observing the same topic, version, and condition from
  multiple tasks creates only one Twitch subscription and fans notifications out locally.

> Important: Direct EventSub WebSocket subscriptions require **user OAuth credentials** with
> the scopes documented on each ``EventSubSubscription`` factory. Calling WebSocket EventSub
> methods with app credentials or an Extension JWT throws
> ``TwitchAuthenticationError/userAccessTokenRequired``.

### Choose a Consumption API

#### AsyncThrowingStream (Recommended)

Use ``TwitchClient/eventStream(for:bufferingPolicy:)`` to consume notifications with Swift
structured concurrency:

```swift
let notifications = try await twitch.eventStream(
  for: .streamOnline(broadcasterID: broadcaster.id)
)

do {
  for try await notification in notifications {
    print(
      notification.sentAt,
      "\(notification.event.broadcasterDisplayName) went live!"
    )
  }
} catch let error as EventSubError {
  print("EventSub ended:", error)
}
```

Each element is an ``EventSubNotification`` containing:

- ``EventSubNotification/event`` — the strongly typed payload (for example,
  ``StreamOnlineEvent``).
- ``EventSubNotification/messageID`` — Twitch's unique envelope ID for deduplication or logging.
- ``EventSubNotification/sentAt`` — the timestamp Twitch recorded when sending the notification.
- ``EventSubNotification/subscriptionID`` — the active Twitch subscription ID.

> Tip: The default `bufferingPolicy` is `.unbounded`. For high-volume topics (such as busy chat
> channels), pass `.bufferingNewest(N)` or `.bufferingOldest(N)` to cap memory usage. Bounded
> policies drop events locally without applying back pressure to Twitch.

> Important: Cancel the consuming `Task` (or let the stream deallocate) to stop observing.
> Breaking out of a `for try await` loop while keeping a strong reference to the stream leaves
> the observer registered.

#### Callbacks

Use ``TwitchClient/eventListener(for:callback:)`` when integrating with callback-driven code.
It returns a ``TwitchCancellable`` that must be cancelled explicitly:

```swift
let subscription = try await twitch.eventListener(
  for: .channelFollow(broadcasterID: broadcaster.id, moderatorID: moderatorID)
) { delivery in
  switch delivery {
  case .event(let notification):
    print("\(notification.event.userDisplayName) followed!")
  case .failure(let error):
    print("Subscription failed:", error)
  case .finished:
    print("Subscription ended cleanly")
  }
}

// When you no longer need updates:
subscription.cancel()
```

Releasing `subscription` without calling ``TwitchCancellable/cancel()`` does **not** remove
the observer. Callbacks have no main-actor guarantee.

#### Combine (Apple Platforms)

On Apple platforms, ``TwitchClient/eventPublisher(for:)`` creates a lazy Combine publisher:

```swift
let cancellable = twitch
  .eventPublisher(for: .streamOnline(broadcasterID: broadcaster.id))
  .sink(
    receiveCompletion: { completion in
      if case .failure(let error) = completion {
        print("EventSub failed:", error)
      }
    },
    receiveValue: { notification in
      print("\(notification.event.broadcasterDisplayName) is live!")
    }
  )
```

Creating the publisher does no network work; each subscriber opens its registration on its
first positive demand and tears it down when cancelled. Notifications arriving while downstream
demand is `.none` are dropped rather than buffered.

### Subscription Sharing and Lifetimes

Two observers requesting identical subscriptions (same account, topic type, schema version,
and condition dictionary) share a single remote Twitch subscription:

- Cancelling one observer removes only that local listener; other observers continue receiving
  notifications uninterrupted.
- When the last observer for a shared subscription leaves, the client schedules upstream
  deletion via Helix automatically.
- Calling ``TwitchClient/resetEventSub()`` (or
  ``TwitchClient/switchCredentials(to:chatBehavior:)``) closes all active EventSub WebSocket
  sessions and finishes all observers normally.

### Handling Errors and Revocations

Two phases can fail differently:

1. **Setup failures** (thrown directly by `eventStream`/`eventListener`, or emitted as the
   Combine publisher's failure) preserve the exact cause:
   ``TwitchAuthenticationError/userAccessTokenRequired``, ``HelixError`` (such as HTTP 403 for
   missing scopes or HTTP 429 rate limiting), ``EventSubError``, or `CancellationError`.
2. **Runtime failures** on an active subscription terminate the observer with ``EventSubError``:
   - ``EventSubError/revocation(_:)`` — Twitch revoked the subscription (check
     ``EventSubRevocation/status`` for reasons like `authorizationRevoked` or `chatUserBanned`).
   - ``EventSubError/disconnected(with:)`` — the WebSocket closed or a reconnect handoff failed.
   - ``EventSubError/timedOut`` — Twitch missed its keepalive or handshake deadline.

Malformed notification payloads do **not** tear down your stream; they are skipped and
reported through <doc:Diagnostics>.

### Custom Subscriptions

If Twitch introduces a new EventSub topic or version before a built-in factory exists, define
an ``Event`` model and pass it to ``EventSubSubscription/custom(type:version:condition:decoding:)``:

```swift
struct CustomPayload: Event {
  let broadcasterUserId: String
}

let custom = EventSubSubscription.custom(
  type: "channel.some_new_event",
  version: "1",
  condition: ["broadcaster_user_id": broadcaster.id],
  decoding: CustomPayload.self
)

let stream = try await twitch.eventStream(for: custom)
```

Custom payloads are decoded with `JSONDecoder` configured for `.convertFromSnakeCase` and
ISO-8601 fractional-second dates (matching built-in ``Event`` models). Leave `decoding` as its
default ``VoidEvent`` when you want to ignore the payload or create a webhook/conduit
subscription through Helix.

### Webhooks and Conduits

Direct WebSocket subscriptions are user-scoped by Twitch design. If you are building a backend
using an app access token with **webhooks** or **EventSub Conduits**, create and manage those
subscriptions directly through Helix endpoints such as
``HelixEndpoint/createEventSubSubscription(using:for:isBatchingEnabled:)``. The library provides the Helix
management endpoints and does not run an HTTP webhook server or conduit shard receiver.

> Important: Direct EventSub WebSockets are not supported on **watchOS**, and on **Linux**
> require `libcurl 8.11.0` or newer. See ``Twitch`` for platform notes.

## See Also

- <doc:Authentication>
- <doc:ManagedChat>
- <doc:Diagnostics>
- ``EventSubSubscription``
- ``EventSubNotification``
- ``EventSubError``
- ``EventSubRevocation``
