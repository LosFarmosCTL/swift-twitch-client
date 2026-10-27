import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the extensions installed by the authenticated user.
  ///
  /// With a user access token, requires `user:read:broadcast` or `user:edit:broadcast`.
  /// Inactive extensions require `user:edit:broadcast`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-user-extensions
  /// ) for request limits and account requirements.
  public static func getUserExtensions()
    -> HelixEndpoint<[UserExtension], UserExtension, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "users/extensions/list",
      authentication: .user,
      makeResponse: { $0.data })
  }
}

/// An extension installed by a user and its activation eligibility.
@MemberwiseInit(.public)
public struct UserExtension: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The extension’s release version.
  public let version: String
  /// The name supplied by Twitch.
  public let name: String
  /// Whether the extension can be activated.
  public let canActivate: Bool
  /// The placements supported by this extension, such as panel, overlay, or component.
  public let types: [ExtensionType]

  enum CodingKeys: String, CodingKey {
    case id
    case version
    case name
    case canActivate
    case types = "type"
  }
}

/// The placements where an extension can appear on Twitch.
public enum ExtensionType: String, Decodable, Sendable {
  /// An extension component rendered over the video.
  case component
  /// An extension view for mobile devices.
  case mobile
  /// An extension overlay on the video.
  case overlay
  /// An extension panel below the video.
  case panel
}
