import Foundation

extension HelixEndpoint {
  public static func deleteVideos(
    ids: [String]
  ) -> HelixEndpoint<[String], String, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "DELETE", path: "videos",
      queryItems: { _ in
        ids.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}
