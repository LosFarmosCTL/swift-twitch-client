import Foundation

extension HelixEndpoint {
  public static func deleteVideos(
    videoIDs: [String]
  ) -> HelixEndpoint<[String], String, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "DELETE", path: "videos",
      queryItems: { _ in
        videoIDs.map { ("id", $0) }
      },
      makeResponse: { $0.data })
  }
}
