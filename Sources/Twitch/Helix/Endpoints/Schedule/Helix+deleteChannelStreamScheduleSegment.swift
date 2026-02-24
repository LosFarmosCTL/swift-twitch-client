import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteChannelStreamScheduleSegment(
    segmentID: String,
    broadcasterID: String? = nil
  ) -> Self {
    return .init(
      method: "DELETE", path: "schedule/segment",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("id", segmentID),
        ]
      })
  }
}
