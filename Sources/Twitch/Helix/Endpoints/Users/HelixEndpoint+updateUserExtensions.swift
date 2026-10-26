import Foundation

extension HelixEndpoint {
  /// Updates the authenticated user’s active extension slots.
  ///
  /// With a user access token, requires `user:edit:broadcast`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-user-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - panel: The panel extension slots, when provided.
  ///   - overlay: The overlay extension slots, when provided.
  ///   - component: The component extension slots, when provided.
  public static func updateUserExtensions(
    panel: [String: ExtensionSlotUpdate]? = nil,
    overlay: [String: ExtensionSlotUpdate]? = nil,
    component: [String: ExtensionSlotUpdate]? = nil
  ) -> HelixEndpoint<
    UserActiveExtensions, UserActiveExtensions,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "PUT", path: "users/extensions",
      body: { _ in
        UpdateUserExtensionsRequestBody(
          data: ExtensionSlotsUpdate(
            panel: panel, overlay: overlay, component: component))
      },
      makeResponse: {
        let activeExtensions = try $0.requireFirst()

        return activeExtensions
      })
  }
}

// swiftlint:disable identifier_name
/// The extension activation and positioning changes to apply to a user’s slot.
public struct ExtensionSlotUpdate: Encodable, Sendable {
  /// Whether the resource is active.
  public let isActive: Bool
  /// The identifier assigned by Twitch, when provided.
  public let id: String?
  /// The extension’s release version.
  public let version: String?
  /// The component slot’s horizontal and vertical position, in pixels, when provided.
  public let x, y: Int?

  /// Creates an extension slot update.
  ///
  /// - Parameters:
  ///   - isActive: Whether the resource is active.
  ///   - id: The identifier assigned by Twitch, when provided.
  ///   - version: The extension’s release version, required when activating an extension.
  ///   - x: The horizontal position, when provided.
  ///   - y: The vertical position, when provided.
  public init(
    isActive: Bool,
    id: String? = nil,
    version: String? = nil,
    x: Int? = nil,
    y: Int? = nil
  ) {
    self.isActive = isActive
    self.id = id
    self.version = version
    self.x = x
    self.y = y
  }

  enum CodingKeys: String, CodingKey {
    case isActive = "active"
    case id, version
    case x, y
  }
}
// swiftlint:enable identifier_name

private struct UpdateUserExtensionsRequestBody: Encodable, Sendable {
  let data: ExtensionSlotsUpdate
}

private struct ExtensionSlotsUpdate: Encodable, Sendable {
  let panel: [String: ExtensionSlotUpdate]?
  let overlay: [String: ExtensionSlotUpdate]?
  let component: [String: ExtensionSlotUpdate]?
}
