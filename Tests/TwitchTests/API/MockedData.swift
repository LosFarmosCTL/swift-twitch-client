import Foundation

public final class MockedData {
  public static let getChannelsJSON: Data = Bundle.module.url(
    forResource: "getChannels", withExtension: "json")!.data
  public static let getMultipleChannelsJSON: Data = Bundle.module.url(
    forResource: "getMultipleChannels", withExtension: "json")!.data
  public static let getChannelsNoBroadcasterIDJSON: Data = Bundle.module.url(
    forResource: "getChannelsNoBroadcasterID", withExtension: "json")!.data
}

extension URL {
  // swiftlint:disable:next force_try
  var data: Data { return try! Data(contentsOf: self) }
}
