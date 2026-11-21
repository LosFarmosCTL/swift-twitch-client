import Foundation

extension HelixEndpoint {
  /// Gets the extensions installed by the authenticated user.
  ///
  /// With a user access token, requires `user:read:broadcast`, `user:edit:broadcast`,
  /// or `channel:manage:extensions`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/users/#get-user-extensions
  /// ) for request limits and account requirements.
  public static func getUserExtensions()
    -> HelixEndpoint<[UserExtension]>
  {
    .init(
      method: "GET", path: "users/extensions/list",
      authentication: .user,
      responseType: UserExtension.self, makeResponse: { $0.data })
  }
}

/// An extension installed by a user and its activation eligibility.
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

  /// Creates a `UserExtension` value.
  public init(
    id: String,
    version: String,
    name: String,
    canActivate: Bool,
    types: [ExtensionType] = []
  ) {
    self.id = id
    self.version = version
    self.name = name
    self.canActivate = canActivate
    self.types = types
  }

  enum CodingKeys: String, CodingKey {
    case id
    case version
    case name
    case canActivate
    case types = "type"
  }
}

/// The placements where an extension can appear on Twitch, preserving unfamiliar values
/// in `rawValue`.
public struct ExtensionType: RawRepresentable, Decodable, Sendable, Hashable {
  /// The exact extension type string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates an extension type from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes an extension type from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// An extension component rendered over the video.
  public static let component = Self(rawValue: "component")
  /// An extension view for mobile devices.
  public static let mobile = Self(rawValue: "mobile")
  /// An extension overlay on the video.
  public static let overlay = Self(rawValue: "overlay")
  /// An extension panel below the video.
  public static let panel = Self(rawValue: "panel")
}
