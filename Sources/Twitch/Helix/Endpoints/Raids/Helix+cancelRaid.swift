import Foundation

extension HelixEndpoint {
  public static func cancelRaid()
    -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void>
  {
    .init(
      method: "DELETE", path: "raids",
      queryItems: { auth in
        [("broadcaster_id", auth.userID)]
      })
  }
}
