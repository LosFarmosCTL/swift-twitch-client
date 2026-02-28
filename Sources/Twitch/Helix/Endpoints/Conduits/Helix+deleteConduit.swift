import Foundation

extension HelixEndpoint {
  public static func deleteConduit(
    id: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "eventsub/conduits",
      queryItems: { _ in
        [
          ("id", id)
        ]
      })
  }
}
