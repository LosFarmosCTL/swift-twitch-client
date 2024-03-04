import Foundation

extension HelixEndpoint where EndpointResponseType == HelixEndpointResponseTypes.Void {
  public static func unblock(_ user: UserID) -> Self {
    return .init(
      method: "DELETE", path: "users/blocks",
      queryItems: { _ in [("target_user_id", user)] })
  }
}
