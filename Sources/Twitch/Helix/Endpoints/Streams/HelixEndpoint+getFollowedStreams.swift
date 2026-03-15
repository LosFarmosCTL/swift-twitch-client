import Foundation

extension HelixEndpoint {
  public static func getFollowedStreams(
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<
    (streams: [Stream], paginationCursor: String?),
    Stream, HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "streams/followed",
      queryItems: { auth in
        [
          ("user_id", auth.userID),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ]
      }, makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}
