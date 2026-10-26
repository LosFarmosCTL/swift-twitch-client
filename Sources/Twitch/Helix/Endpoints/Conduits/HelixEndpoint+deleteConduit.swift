import Foundation

extension HelixEndpoint {
  public static func deleteConduit(
    conduitID: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "DELETE", path: "eventsub/conduits",
      queryItems: { _ in
        [
          ("id", conduitID)
        ]
      })
  }
}
