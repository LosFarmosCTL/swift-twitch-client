import Foundation

extension HelixEndpoint {
  public static func deleteCustomReward(
    _ rewardID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "channel_points/custom_rewards",
      queryItems: { auth in
        [
          ("broadcaster_id", broadcasterID ?? auth.userID),
          ("id", rewardID),
        ]
      })
  }
}
