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
  public static func charityDonation(broadcasterID: String)
    -> EventSubSubscription<CharityDonationEvent>
  {
    .init(
      type: "channel.charity_campaign.donate", version: "1",
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
  public static func charityCampaignStart(broadcasterID: String)
    -> EventSubSubscription<CharityCampaignStartEvent>
  {
    .init(
      type: "channel.charity_campaign.start", version: "1",
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
  public static func charityCampaignProgress(broadcasterID: String)
    -> EventSubSubscription<CharityCampaignProgressEvent>
  {
    .init(
      type: "channel.charity_campaign.progress", version: "1",
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
  public static func charityCampaignStop(broadcasterID: String)
    -> EventSubSubscription<CharityCampaignStopEvent>
  {
    .init(
      type: "channel.charity_campaign.stop", version: "1",
      condition: [
        "broadcaster_user_id": broadcasterID
      ])
  }
}
