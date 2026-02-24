import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == UserActiveExtensions, HelixResponseType == UserActiveExtensions
{
  public static func updateUserExtensions(
    panel: [String: ExtensionSlotUpdate]? = nil,
    overlay: [String: ExtensionSlotUpdate]? = nil,
    component: [String: ExtensionSlotUpdate]? = nil
  ) -> Self {
    return .init(
      method: "PUT", path: "users/extensions",
      body: { _ in
        UpdateUserExtensionsRequestBody(
          data: ExtensionSlotsUpdate(
            panel: panel, overlay: overlay, component: component))
      },
      makeResponse: {
        guard let activeExtensions = $0.data.first else {
          throw HelixError.noDataInResponse(responseData: $0.rawData)
        }

        return activeExtensions
      })
  }
}

// swiftlint:disable identifier_name
public struct ExtensionSlotUpdate: Encodable, Sendable {
  public let isActive: Bool
  public let id: String?
  public let version: String?
  public let x, y: Int?

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
