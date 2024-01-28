import Foundation

public final class MockedData {
  public static let paginatedResponseJSON: Data = Bundle.module.url(
    forResource: "paginatedResponse", withExtension: "json")!.data
  public static let errorResponseJSON: Data = Bundle.module.url(
    forResource: "errorResponse", withExtension: "json")!.data

  public static let getChannelsJSON: Data = Bundle.module.url(
    forResource: "getChannels", withExtension: "json")!.data

  public static let getExtensionAnalyticsJSON: Data = Bundle.module.url(
    forResource: "getExtensionAnalytics", withExtension: "json")!.data
  public static let getGameAnalyticsJSON: Data = Bundle.module.url(
    forResource: "getGameAnalytics", withExtension: "json")!.data

  public static let getAdScheduleJSON: Data = Bundle.module.url(
    forResource: "getAdSchedule", withExtension: "json")!.data
  public static let startCommercialJSON: Data = Bundle.module.url(
    forResource: "startCommercial", withExtension: "json")!.data
  public static let snoozeNextAdJSON: Data = Bundle.module.url(
    forResource: "snoozeNextAd", withExtension: "json")!.data
}

extension URL {
  // swiftlint:disable:next force_try
  var data: Data { return try! Data(contentsOf: self) }
}
