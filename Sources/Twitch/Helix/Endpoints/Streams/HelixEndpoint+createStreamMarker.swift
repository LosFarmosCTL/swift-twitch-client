import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Adds a marker to a broadcaster’s current stream.
  ///
  /// With a user access token, requires `channel:manage:broadcast`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-stream-marker
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The user’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  ///   - description: An optional label for the marker, up to 140 characters.
  public static func createStreamMarker(
    for userID: String? = nil,
    description: String? = nil
  ) -> HelixEndpoint<StreamMarker, StreamMarker, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "streams/markers",
      authentication: .user,
      body: { credentials in
        CreateStreamMarkerRequestBody(
          userID: try credentials.resolveUserID(userID, parameter: "user_id"),
          description: description)
      },
      makeResponse: { response in
        let marker = try response.requireFirst()

        return marker
      })
  }
}

private struct CreateStreamMarkerRequestBody: Encodable, Sendable {
  let userID: String
  let description: String?
}

/// A timestamped marker created in a broadcast.
@MemberwiseInit(.public)
public struct StreamMarker: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The time the resource was created.
  public let createdAt: Date
  /// The position within the video, in seconds.
  public let positionSeconds: Int
  /// The descriptive text supplied by Twitch.
  public let description: String
}
