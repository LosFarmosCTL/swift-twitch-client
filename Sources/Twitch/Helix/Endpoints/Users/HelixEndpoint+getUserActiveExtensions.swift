import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the extensions active on a user’s channel.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-user-active-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The user’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  public static func getUserActiveExtensions(
    userID: String? = nil
  ) -> HelixEndpoint<
    UserActiveExtensions, UserActiveExtensions,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "users/extensions",
      queryItems: { credentials in
        [("user_id", userID ?? credentials.userID)]
      },
      makeResponse: {
        let activeExtensions = try $0.requireFirst()

        return activeExtensions
      })
  }
}

/// The active extension assignments for a user’s panel, overlay, and component slots.
@MemberwiseInit(.public)
public struct UserActiveExtensions: Decodable, Sendable {
  /// The panel extension slots, when provided.
  public let panel: [String: ExtensionSlot]?
  /// The overlay extension slots, when provided.
  public let overlay: [String: ExtensionSlot]?
  /// The component extension slots, when provided.
  public let component: [String: ExtensionSlot]?
}

// swiftlint:disable identifier_name
/// An extension installed in a numbered channel slot.
@MemberwiseInit(.public)
public struct ExtensionSlot: Decodable, Sendable {
  /// Whether the resource is active.
  public let isActive: Bool
  /// The identifier assigned by Twitch, when provided.
  public let id: String?
  /// The extension’s release version.
  public let version: String?
  /// The name supplied by Twitch, when provided.
  public let name: String?
  /// The horizontal position, when provided.
  public let x: Int?
  /// The vertical position, when provided.
  public let y: Int?

  enum CodingKeys: String, CodingKey {
    case isActive = "active"
    case id, version, name
    case x, y
  }
}
// swiftlint:enable identifier_name
