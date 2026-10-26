extension EventSubSubscription {
  /// Creates a subscription description for charity donation notifications.
  ///
  /// Requires `channel:read:charity`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaigndonate
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func charityDonation(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityDonationEvent>
  {
    .init(
      type: EventType.charityDonation.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for charity campaign start notifications.
  ///
  /// Requires `channel:read:charity`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstart
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func charityCampaignStart(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignStartEvent>
  {
    .init(
      type: EventType.charityCampaignStart.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for charity campaign progress notifications.
  ///
  /// Requires `channel:read:charity`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignprogress
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func charityCampaignProgress(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignProgressEvent>
  {
    .init(
      type: EventType.charityCampaignProgress.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }

  /// Creates a subscription description for charity campaign stop notifications.
  ///
  /// Requires `channel:read:charity`. The broadcaster must grant the required scope; with
  /// WebSockets, use that broadcaster’s user token.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/eventsub/eventsub-subscription-types/#channelcharity_campaignstop
  /// ) for conditions and transport-specific authorization.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - version: The EventSub subscription schema version. Defaults to `"1"`.
  public static func charityCampaignStop(broadcasterID: String, version: String = "1")
    -> EventSubSubscription<CharityCampaignStopEvent>
  {
    .init(
      type: EventType.charityCampaignStop.rawValue, version: version,
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
