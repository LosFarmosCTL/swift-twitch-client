import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == ([StreamMarkersByUser], String?),
  HelixResponseType == StreamMarkersByUser
{
  public static func getStreamMarkers(
    userID: String? = nil,
    videoID: String? = nil,
    limit: Int? = nil,
    before endCursor: String? = nil,
    after startCursor: String? = nil
  ) -> Self {
    return .init(
      method: "GET", path: "streams/markers",
      queryItems: { auth in
        let resolvedUserID = videoID == nil ? (userID ?? auth.userID) : nil

        return [
          ("user_id", resolvedUserID),
          ("video_id", videoID),
          ("first", limit.map(String.init)),
          ("before", endCursor),
          ("after", startCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

public struct StreamMarkersByUser: Decodable, Sendable {
  public let userID: String
  public let userName: String
  public let userLogin: String
  public let videos: [StreamMarkersVideo]

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userName
    case userLogin
    case videos
  }
}

public struct StreamMarkersVideo: Decodable, Sendable {
  public let videoID: String
  public let markers: [StreamMarker]

  enum CodingKeys: String, CodingKey {
    case videoID = "videoId"
    case markers
  }

  public struct StreamMarker: Decodable, Sendable {
    public let id: String
    public let createdAt: Date
    public let positionSeconds: Int
    public let description: String
    public let url: String
  }
}
