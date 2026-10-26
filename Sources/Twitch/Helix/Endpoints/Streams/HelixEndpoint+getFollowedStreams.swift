import Foundation

extension HelixEndpoint {
  public static func getFollowedStreams(
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (streams: [Stream], cursor: String?),
    Stream, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "streams/followed",
      queryItems: { credentials in
        [
          ("user_id", credentials.userID),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
