import Foundation

extension HelixEndpoint {
  /// Gets the extensions active on a user’s channel.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/users/#get-user-active-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userID: The user’s Twitch user ID; `nil` uses the executing client’s
  ///     authenticated user ID.
  /// App tokens require an explicit target ID.
  public static func getUserActiveExtensions(
    userID: String? = nil
  ) -> HelixEndpoint<UserActiveExtensions> {
    .init(
      method: "GET", path: "users/extensions",
      authentication: .either,
      queryItems: { credentials in
        [("user_id", try credentials.resolveUserID(userID, parameter: "user_id"))]
      },
      responseType: UserActiveExtensions.self,
      makeResponse: {
        let activeExtensions = try $0.requireFirst()

        return activeExtensions
      })
  }
}

/// The active extension assignments for a user’s panel, overlay, and component slots.
public struct UserActiveExtensions: Decodable, Sendable {
  /// The panel extension slots, when provided.
  public let panel: [String: ExtensionSlot]?
  /// The overlay extension slots, when provided.
  public let overlay: [String: ExtensionSlot]?
  /// The component extension slots, when provided.
  public let component: [String: ExtensionSlot]?

  /// Creates a `UserActiveExtensions` value.
  public init(
    panel: [String: ExtensionSlot]? = nil,
    overlay: [String: ExtensionSlot]? = nil,
    component: [String: ExtensionSlot]? = nil
  ) {
    self.panel = panel
    self.overlay = overlay
    self.component = component
  }
}

// swiftlint:disable identifier_name
/// An extension installed in a numbered channel slot.
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

  /// Creates an `ExtensionSlot` value.
  public init(
    isActive: Bool,
    id: String? = nil,
    version: String? = nil,
    name: String? = nil,
    x: Int? = nil,
    y: Int? = nil
  ) {
    self.isActive = isActive
    self.id = id
    self.version = version
    self.name = name
    self.x = x
    self.y = y
  }

  enum CodingKeys: String, CodingKey {
    case isActive = "active"
    case id, version, name
    case x, y
  }
}
// swiftlint:enable identifier_name
