import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Stream> {
  public static func getFollowedStreams(
    of userId: String, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("user_id", userId),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "streams/followed", queryItems: queryItems)
  }
}
