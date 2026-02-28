import Foundation

extension HelixEndpoint {
  public static func unblock(_ user: String)
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    return .init(
      method: "DELETE", path: "users/blocks",
      queryItems: { _ in [("target_user_id", user)] })
  }
}
