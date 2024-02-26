import Foundation

extension HelixEndpoint where Response == ResponseTypes.Array<Stream> {
  public static func getFollowedStreams(
    of user: UserID, limit: Int? = nil, after cursor: String? = nil
  ) -> Self {
    let queryItems = self.makeQueryItems(
      ("user_id", user),
      ("first", limit.map(String.init)),
      ("after", cursor))

    return .init(method: "GET", path: "streams/followed", queryItems: queryItems)
  }
}
