import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Creates a clip from a broadcaster’s stream.
  ///
  /// With a user access token, requires `clips:edit`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#create-clip
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - title: The title shown to viewers, when provided.
  ///   - duration: The clip duration in seconds.
  public static func createClip(
    broadcasterID: String? = nil,
    title: String? = nil,
    duration: Double? = nil
  ) -> HelixEndpoint<ClipCreation, ClipCreation, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "POST", path: "clips",
      authentication: .user,
      queryItems: { credentials in
        return [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          ),
          ("title", title),
          ("duration", duration.map(String.init(describing:))),
        ]
      },
      makeResponse: {
        let clip = try $0.requireFirst()

        return clip
      })
  }
}

/// The clip identifier and editing URL returned after creating a clip.
@MemberwiseInit(.public)
public struct ClipCreation: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The URL for edit.
  public let editURL: String

  enum CodingKeys: String, CodingKey {
    case id
    case editURL = "editUrl"
  }
}
