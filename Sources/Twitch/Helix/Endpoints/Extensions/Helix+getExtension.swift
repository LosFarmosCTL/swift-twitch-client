import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == Extension, HelixResponseType == Extension
{
  public static func getExtension(
    extensionID: String,
    version: String? = nil
  ) -> Self {
    .init(
      method: "GET", path: "extensions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("extension_version", version),
        ]
      },
      makeResponse: { response in
        guard let extensionInfo = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return extensionInfo
      })
  }
}

public struct Extension: Decodable, Sendable {
  public let authorName: String
  public let bitsEnabled: Bool
  public let canInstall: Bool
  public let configurationLocation: ExtensionConfigurationLocation
  public let description: String?
  public let eulaTosUrl: String?
  public let hasChatSupport: Bool
  public let iconUrl: String
  public let iconUrls: [String: String]?
  public let id: String
  public let name: String
  public let privacyPolicyUrl: String?
  public let requestIdentityLink: Bool
  public let screenshotUrls: [String]?
  public let state: ExtensionState
  public let subscriptionsSupportLevel: ExtensionSubscriptionSupportLevel
  public let summary: String?
  public let supportEmail: String?
  public let version: String
  public let viewerSummary: String?
  public let views: ExtensionViews?
  public let allowlistedConfigUrls: [String]?
  public let allowlistedPanelUrls: [String]?

  public struct ExtensionViews: Decodable, Sendable {
    public let mobile: ExtensionView?
    public let panel: ExtensionPanelView?
    public let videoOverlay: ExtensionView?
    public let component: ExtensionComponentView?
  }

  public struct ExtensionView: Decodable, Sendable {
    public let viewerUrl: String
    public let canLinkExternalContent: Bool?
  }

  public struct ExtensionPanelView: Decodable, Sendable {
    public let viewerUrl: String
    public let height: Int
    public let canLinkExternalContent: Bool
  }

  public struct ExtensionComponentView: Decodable, Sendable {
    public let viewerUrl: String
    public let aspectRatioX: Int?
    public let aspectRatioY: Int?
    public let autoscale: Bool?
    public let scalePixels: Int?
    public let targetHeight: Int?
    public let canLinkExternalContent: Bool?
  }

  public enum ExtensionConfigurationLocation: String, Decodable, Sendable {
    case hosted
    case custom
    case none
  }

  public enum ExtensionState: String, Decodable, Sendable {
    case approved = "Approved"
    case assetsUploaded = "AssetsUploaded"
    case deleted = "Deleted"
    case deprecated = "Deprecated"
    case inReview = "InReview"
    case inTest = "InTest"
    case pendingAction = "PendingAction"
    case rejected = "Rejected"
    case released = "Released"
  }

  public enum ExtensionSubscriptionSupportLevel: String, Decodable, Sendable {
    case none
    case optional
  }
}
