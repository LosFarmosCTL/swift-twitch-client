import Foundation

extension HelixEndpoint {
  public static func deleteChannelStreamScheduleSegment(
    segmentID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "schedule/segment",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("id", segmentID),
        ]
      })
  }
}
