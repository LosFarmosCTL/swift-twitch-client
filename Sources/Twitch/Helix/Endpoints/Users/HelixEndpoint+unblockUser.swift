import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func unblock(_ user: String) -> Self {
    return .init(
      method: "DELETE", path: "users/blocks",
      queryItems: { _ in [("target_user_id", user)] })
  }
}
