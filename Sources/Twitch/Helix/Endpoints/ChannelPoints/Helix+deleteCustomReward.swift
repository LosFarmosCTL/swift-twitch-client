import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func deleteCustomReward(
    _ rewardID: String,
    broadcasterID: UserID? = nil
  ) -> Self {
    return .init(
      method: "DELETE", path: "channel_points/custom_rewards",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("id", rewardID),
        ]
      })
  }
}
