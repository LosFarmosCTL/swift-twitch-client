import Foundation

extension HelixEndpoint {
  public static func deleteCustomReward(
    _ rewardID: String,
    broadcasterID: String? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "channel_points/custom_rewards",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("id", rewardID),
        ]
      })
  }
}
