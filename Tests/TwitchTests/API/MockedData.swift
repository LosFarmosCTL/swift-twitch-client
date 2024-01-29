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

  public static let getGamesJSON: Data = Bundle.module.url(
    forResource: "getGames", withExtension: "json")!.data
  public static let getTopGamesJSON: Data = Bundle.module.url(
    forResource: "getTopGames", withExtension: "json")!.data

  public static let searchCategoriesJSON: Data = Bundle.module.url(
    forResource: "searchCategories", withExtension: "json")!.data
  public static let searchChannelsJSON: Data = Bundle.module.url(
    forResource: "searchChannels", withExtension: "json")!.data
}

extension URL {
  // swiftlint:disable:next force_try
  var data: Data { return try! Data(contentsOf: self) }
}
