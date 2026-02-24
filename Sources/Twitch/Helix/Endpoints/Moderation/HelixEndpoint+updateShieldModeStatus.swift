import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ShieldModeStatus, HelixResponseType == ShieldModeStatus
{
  public static func updateShieldModeStatus(
    of channel: String, isActive: Bool
  ) -> Self {
    return .init(
      method: "PUT", path: "moderation/shield_mode",
      queryItems: { auth in
        [
          ("broadcaster_id", channel),
          ("moderator_id", auth.userID),
        ]
      }, body: { _ in ["is_active": isActive] },
      makeResponse: {
        guard let status = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }
        return status
      })
  }
}
