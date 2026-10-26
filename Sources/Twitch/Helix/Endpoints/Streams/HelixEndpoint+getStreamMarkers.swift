import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getStreamMarkers(
    for userID: String? = nil,
    videoID: String? = nil,
    limit: Int? = nil,
    before beforeCursor: String? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (users: [StreamMarkersByUser], cursor: String?), StreamMarkersByUser,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "streams/markers",
      queryItems: { credentials in
        let resolvedUserID = videoID == nil ? (userID ?? credentials.userID) : nil

        return [
          ("user_id", resolvedUserID),
          ("video_id", videoID),
          ("first", limit.map(String.init)),
          ("before", beforeCursor),
          ("after", afterCursor),
        ]
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

@MemberwiseInit(.public)
public struct StreamMarkersByUser: Decodable, Sendable {
  public let userID: String
  public let userDisplayName: String
  public let userLogin: String
  public let videos: [StreamMarkersVideo]

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case videos
  }
}

@MemberwiseInit(.public)
public struct StreamMarkersVideo: Decodable, Sendable {
  public let videoID: String
  public let markers: [StreamMarker]

  enum CodingKeys: String, CodingKey {
    case videoID = "videoId"
    case markers
  }

  @MemberwiseInit(.public)
  public struct StreamMarker: Decodable, Sendable {
    public let id: String
    public let createdAt: Date
    public let positionSeconds: Int
    public let description: String
    public let url: String
  }
}
