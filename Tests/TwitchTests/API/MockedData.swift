import Foundation

public final class MockedData {
  public static let paginatedResponseJSON: Data = Bundle.module.url(
    forResource: "paginatedResponse", withExtension: "json")!.data
  public static let errorResponseJSON: Data = Bundle.module.url(
    forResource: "errorResponse", withExtension: "json")!.data

  public static let getAdScheduleJSON: Data = Bundle.module.url(
    forResource: "getAdSchedule", withExtension: "json")!.data
  public static let startCommercialJSON: Data = Bundle.module.url(
    forResource: "startCommercial", withExtension: "json")!.data
  public static let snoozeNextAdJSON: Data = Bundle.module.url(
    forResource: "snoozeNextAd", withExtension: "json")!.data

  public static let getExtensionAnalyticsJSON: Data = Bundle.module.url(
    forResource: "getExtensionAnalytics", withExtension: "json")!.data
  public static let getGameAnalyticsJSON: Data = Bundle.module.url(
    forResource: "getGameAnalytics", withExtension: "json")!.data

  public static let getExtensionConfigurationSegmentJSON: Data = Bundle.module.url(
    forResource: "getExtensionConfigurationSegment", withExtension: "json")!.data
  public static let setExtensionConfigurationSegmentJSON: Data = Bundle.module.url(
    forResource: "setExtensionConfigurationSegment", withExtension: "json")!.data
  public static let sendExtensionPubSubMessageJSON: Data = Bundle.module.url(
    forResource: "sendExtensionPubSubMessage", withExtension: "json")!.data
  public static let getExtensionLiveChannelsJSON: Data = Bundle.module.url(
    forResource: "getExtensionLiveChannels", withExtension: "json")!.data
  public static let getExtensionSecretsJSON: Data = Bundle.module.url(
    forResource: "getExtensionSecrets", withExtension: "json")!.data
  public static let createExtensionSecretJSON: Data = Bundle.module.url(
    forResource: "createExtensionSecret", withExtension: "json")!.data
  public static let sendExtensionChatMessageJSON: Data = Bundle.module.url(
    forResource: "sendExtensionChatMessage", withExtension: "json")!.data
  public static let getExtensionJSON: Data = Bundle.module.url(
    forResource: "getExtension", withExtension: "json")!.data
  public static let getReleasedExtensionJSON: Data = Bundle.module.url(
    forResource: "getReleasedExtension", withExtension: "json")!.data
  public static let getExtensionBitsProductsJSON: Data = Bundle.module.url(
    forResource: "getExtensionBitsProducts", withExtension: "json")!.data
  public static let updateExtensionBitsProductJSON: Data = Bundle.module.url(
    forResource: "updateExtensionBitsProduct", withExtension: "json")!.data

  public static let getBitsLeaderboardJSON: Data = Bundle.module.url(
    forResource: "getBitsLeaderboard", withExtension: "json")!.data
  public static let getCheermotesJSON: Data = Bundle.module.url(
    forResource: "getCheermotes", withExtension: "json")!.data
  public static let getExtensionPredictionsJSON: Data = Bundle.module.url(
    forResource: "getExtensionPredictions", withExtension: "json")!.data

  public static let getChannelsJSON: Data = Bundle.module.url(
    forResource: "getChannels", withExtension: "json")!.data
  public static let getChannelEditorsJSON: Data = Bundle.module.url(
    forResource: "getChannelEditors", withExtension: "json")!.data
  public static let getFollowedChannelsJSON: Data = Bundle.module.url(
    forResource: "getFollowedChannels", withExtension: "json")!.data
  public static let checkFollowJSON: Data = Bundle.module.url(
    forResource: "checkFollow", withExtension: "json")!.data
  public static let getChannelFollowersJSON: Data = Bundle.module.url(
    forResource: "getChannelFollowers", withExtension: "json")!.data
  public static let checkChannelFollowerJSON: Data = Bundle.module.url(
    forResource: "checkChannelFollower", withExtension: "json")!.data

  public static let createCustomRewardJSON: Data = Bundle.module.url(
    forResource: "createCustomReward", withExtension: "json")!.data
  public static let getCustomRewardsJSON: Data = Bundle.module.url(
    forResource: "getCustomRewards", withExtension: "json")!.data
  public static let getCustomRewardRedemptionsJSON: Data = Bundle.module.url(
    forResource: "getCustomRewardRedemptions", withExtension: "json")!.data
  public static let updateCustomRewardJSON: Data = Bundle.module.url(
    forResource: "updateCustomReward", withExtension: "json")!.data
  public static let updateRedemptionStatusJSON: Data = Bundle.module.url(
    forResource: "updateRedemptionStatus", withExtension: "json")!.data

  public static let getChattersJSON: Data = Bundle.module.url(
    forResource: "getChatters", withExtension: "json")!.data
  public static let getChannelEmotesJSON: Data = Bundle.module.url(
    forResource: "getChannelEmotes", withExtension: "json")!.data
  public static let getGlobalEmotesJSON: Data = Bundle.module.url(
    forResource: "getGlobalEmotes", withExtension: "json")!.data
  public static let getEmoteSetsJSON: Data = Bundle.module.url(
    forResource: "getEmoteSets", withExtension: "json")!.data
  public static let getChannelBadgesJSON: Data = Bundle.module.url(
    forResource: "getChannelBadges", withExtension: "json")!.data
  public static let getGlobalBadgesJSON: Data = Bundle.module.url(
    forResource: "getGlobalBadges", withExtension: "json")!.data
  public static let getChatSettingsJSON: Data = Bundle.module.url(
    forResource: "getChatSettings", withExtension: "json")!.data
  public static let getUserColorJSON: Data = Bundle.module.url(
    forResource: "getUserColor", withExtension: "json")!.data
  public static let getContentClassificationLabelsJSON: Data = Bundle.module.url(
    forResource: "getContentClassificationLabels", withExtension: "json")!.data

  public static let getDropsEntitlementsJSON: Data = Bundle.module.url(
    forResource: "getDropsEntitlements", withExtension: "json")!.data
  public static let updateDropsEntitlementsJSON: Data = Bundle.module.url(
    forResource: "updateDropsEntitlements", withExtension: "json")!.data

  public static let createClipJSON: Data = Bundle.module.url(
    forResource: "createClip", withExtension: "json")!.data
  public static let getClipsJSON: Data = Bundle.module.url(
    forResource: "getClips", withExtension: "json")!.data

  public static let getCharityCampaignJSON: Data = Bundle.module.url(
    forResource: "getCharityCampaign", withExtension: "json")!.data
  public static let getCharityCampaignDonationsJSON: Data = Bundle.module.url(
    forResource: "getCharityCampaignDonations", withExtension: "json")!.data

  public static let getGamesJSON: Data = Bundle.module.url(
    forResource: "getGames", withExtension: "json")!.data
  public static let getTopGamesJSON: Data = Bundle.module.url(
    forResource: "getTopGames", withExtension: "json")!.data

  public static let getCreatorGoalsJSON: Data = Bundle.module.url(
    forResource: "getCreatorGoals", withExtension: "json")!.data

  public static let getChannelGuestStarSettingsJSON: Data = Bundle.module.url(
    forResource: "getChannelGuestStarSettings", withExtension: "json")!.data
  public static let getGuestStarSessionJSON: Data = Bundle.module.url(
    forResource: "getGuestStarSession", withExtension: "json")!.data
  public static let createGuestStarSessionJSON: Data = Bundle.module.url(
    forResource: "createGuestStarSession", withExtension: "json")!.data
  public static let endGuestStarSessionJSON: Data = Bundle.module.url(
    forResource: "endGuestStarSession", withExtension: "json")!.data
  public static let getGuestStarInvitesJSON: Data = Bundle.module.url(
    forResource: "getGuestStarInvites", withExtension: "json")!.data

  public static let checkAutomodStatusJSON: Data = Bundle.module.url(
    forResource: "checkAutomodStatus", withExtension: "json")!.data
  public static let getAutomodSettingsJSON: Data = Bundle.module.url(
    forResource: "getAutomodSettings", withExtension: "json")!.data
  public static let updateAutomodSettingsJSON: Data = Bundle.module.url(
    forResource: "updateAutomodSettings", withExtension: "json")!.data
  public static let getBannedUsersJSON: Data = Bundle.module.url(
    forResource: "getBannedUsers", withExtension: "json")!.data
  public static let banUserJSON: Data = Bundle.module.url(
    forResource: "banUser", withExtension: "json")!.data
  public static let getBlockedTermsJSON: Data = Bundle.module.url(
    forResource: "getBlockedTerms", withExtension: "json")!.data
  public static let getModeratedChannelsJSON: Data = Bundle.module.url(
    forResource: "getModeratedChannels", withExtension: "json")!.data
  public static let getModeratorsJSON: Data = Bundle.module.url(
    forResource: "getModerators", withExtension: "json")!.data
  public static let getVIPsJSON: Data = Bundle.module.url(
    forResource: "getVIPs", withExtension: "json")!.data
  public static let getShieldModeStatusJSON: Data = Bundle.module.url(
    forResource: "getShieldModeStatus", withExtension: "json")!.data

  public static let searchCategoriesJSON: Data = Bundle.module.url(
    forResource: "searchCategories", withExtension: "json")!.data
  public static let searchChannelsJSON: Data = Bundle.module.url(
    forResource: "searchChannels", withExtension: "json")!.data

  public static let getStreamsJSON: Data = Bundle.module.url(
    forResource: "getStreams", withExtension: "json")!.data
  public static let getFollowedStreamsJSON: Data = Bundle.module.url(
    forResource: "getFollowedStreams", withExtension: "json")!.data

  public static let getPredictionsJSON: Data = Bundle.module.url(
    forResource: "getPredictions", withExtension: "json")!.data
  public static let createPredictionJSON: Data = Bundle.module.url(
    forResource: "createPrediction", withExtension: "json")!.data
  public static let endPredictionJSON: Data = Bundle.module.url(
    forResource: "endPrediction", withExtension: "json")!.data
  public static let getStreamKeyJSON: Data = Bundle.module.url(
    forResource: "getStreamKey", withExtension: "json")!.data
  public static let createStreamMarkerJSON: Data = Bundle.module.url(
    forResource: "createStreamMarker", withExtension: "json")!.data
  public static let getStreamMarkersJSON: Data = Bundle.module.url(
    forResource: "getStreamMarkers", withExtension: "json")!.data

  public static let getPollsJSON: Data = Bundle.module.url(
    forResource: "getPolls", withExtension: "json")!.data
  public static let createPollJSON: Data = Bundle.module.url(
    forResource: "createPoll", withExtension: "json")!.data
  public static let endPollJSON: Data = Bundle.module.url(
    forResource: "endPoll", withExtension: "json")!.data

  public static let getConduitsJSON: Data = Bundle.module.url(
    forResource: "getConduits", withExtension: "json")!.data
  public static let createConduitJSON: Data = Bundle.module.url(
    forResource: "createConduit", withExtension: "json")!.data
  public static let updateConduitJSON: Data = Bundle.module.url(
    forResource: "updateConduit", withExtension: "json")!.data
  public static let getConduitShardsJSON: Data = Bundle.module.url(
    forResource: "getConduitShards", withExtension: "json")!.data
  public static let updateConduitShardsJSON: Data = Bundle.module.url(
    forResource: "updateConduitShards", withExtension: "json")!.data

  public static let getEventSubSubscriptionsJSON: Data = Bundle.module.url(
    forResource: "getEventSubSubscriptions", withExtension: "json")!.data
  public static let createEventSubSubscriptionJSON: Data = Bundle.module.url(
    forResource: "createEventSubSubscription", withExtension: "json")!.data

  public static let getVideosJSON: Data = Bundle.module.url(
    forResource: "getVideos", withExtension: "json")!.data
  public static let deleteVideosJSON: Data = Bundle.module.url(
    forResource: "deleteVideos", withExtension: "json")!.data

  public static let getHypeTrainStatusJSON: Data = Bundle.module.url(
    forResource: "getHypeTrainStatus", withExtension: "json")!.data

  public static let getBroadcasterSubscriptionsJSON: Data = Bundle.module.url(
    forResource: "getBroadcasterSubscriptions", withExtension: "json")!.data
  public static let checkUserSubscriptionJSON: Data = Bundle.module.url(
    forResource: "checkUserSubscription", withExtension: "json")!.data

  public static let createChannelStreamScheduleSegmentJSON: Data = Bundle.module.url(
    forResource: "createChannelStreamScheduleSegment", withExtension: "json")!.data
  public static let updateChannelStreamScheduleSegmentJSON: Data = Bundle.module.url(
    forResource: "updateChannelStreamScheduleSegment", withExtension: "json")!.data
  public static let getChanneliCalendarICS: Data = Bundle.module.url(
    forResource: "getChanneliCalendar", withExtension: "ics")!.data

  public static let startRaidJSON: Data = Bundle.module.url(
    forResource: "startRaid", withExtension: "json")!.data
  public static let cancelRaidJSON: Data = Bundle.module.url(
    forResource: "cancelRaid", withExtension: "json")!.data

  public static let getChannelTeamsJSON: Data = Bundle.module.url(
    forResource: "getChannelTeams", withExtension: "json")!.data
  public static let getTeamsJSON: Data = Bundle.module.url(
    forResource: "getTeams", withExtension: "json")!.data

  public static let getUsersJSON: Data = Bundle.module.url(
    forResource: "getUsers", withExtension: "json")!.data
  public static let updateUserJSON: Data = Bundle.module.url(
    forResource: "updateUser", withExtension: "json")!.data
  public static let getUserBlocklistJSON: Data = Bundle.module.url(
    forResource: "getUserBlocklist", withExtension: "json")!.data
  public static let getUserExtensionsJSON: Data = Bundle.module.url(
    forResource: "getUserExtensions", withExtension: "json")!.data
  public static let getUserActiveExtensionsJSON: Data = Bundle.module.url(
    forResource: "getUserActiveExtensions", withExtension: "json")!.data
  public static let updateUserExtensionsJSON: Data = Bundle.module.url(
    forResource: "updateUserExtensions", withExtension: "json")!.data
}

extension URL {
  // swiftlint:disable:next force_try
  var data: Data { return try! Data(contentsOf: self) }
}
