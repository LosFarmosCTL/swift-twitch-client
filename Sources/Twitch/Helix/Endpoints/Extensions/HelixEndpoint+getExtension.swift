import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getExtension(
    extensionID: String,
    version: String? = nil
  ) -> HelixEndpoint<Extension, Extension, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "extensions",
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("extension_version", version),
        ]
      },
      makeResponse: { response in
        let extensionInfo = try response.requireFirst()

        return extensionInfo
      })
  }
}

@MemberwiseInit(.public)
public struct Extension: Decodable, Sendable {
  public let authorName: String
  public let bitsEnabled: Bool
  public let canInstall: Bool
  public let configurationLocation: ExtensionConfigurationLocation
  public let description: String?
  public let eulaTOSURL: String?
  public let hasChatSupport: Bool
  public let iconURL: String
  public let iconURLs: [String: String]?
  public let id: String
  public let name: String
  public let privacyPolicyURL: String?
  public let requestIdentityLink: Bool
  public let screenshotURLs: [String]?
  public let state: ExtensionState
  public let subscriptionsSupportLevel: ExtensionSubscriptionSupportLevel
  public let summary: String?
  public let supportEmail: String?
  public let version: String
  public let viewerSummary: String?
  public let views: ExtensionViews?
  public let allowlistedConfigURLs: [String]?
  public let allowlistedPanelURLs: [String]?

  @MemberwiseInit(.public)
  public struct ExtensionViews: Decodable, Sendable {
    public let mobile: ExtensionView?
    public let panel: ExtensionPanelView?
    public let videoOverlay: ExtensionView?
    public let component: ExtensionComponentView?
  }

  @MemberwiseInit(.public)
  public struct ExtensionView: Decodable, Sendable {
    public let viewerURL: String
    public let canLinkExternalContent: Bool?

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case canLinkExternalContent
    }
  }

  @MemberwiseInit(.public)
  public struct ExtensionPanelView: Decodable, Sendable {
    public let viewerURL: String
    public let height: Int
    public let canLinkExternalContent: Bool

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case height
      case canLinkExternalContent
    }
  }

  @MemberwiseInit(.public)
  public struct ExtensionComponentView: Decodable, Sendable {
    public let viewerURL: String
    public let aspectRatioX: Int?
    public let aspectRatioY: Int?
    public let autoscale: Bool?
    public let scalePixels: Int?
    public let targetHeight: Int?
    public let canLinkExternalContent: Bool?

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case aspectRatioX
      case aspectRatioY
      case autoscale
      case scalePixels
      case targetHeight
      case canLinkExternalContent
    }
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

  enum CodingKeys: String, CodingKey {
    case authorName
    case bitsEnabled
    case canInstall
    case configurationLocation
    case description
    case eulaTOSURL = "eulaTosUrl"
    case hasChatSupport
    case iconURL = "iconUrl"
    case iconURLs = "iconUrls"
    case id
    case name
    case privacyPolicyURL = "privacyPolicyUrl"
    case requestIdentityLink
    case screenshotURLs = "screenshotUrls"
    case state
    case subscriptionsSupportLevel
    case summary
    case supportEmail
    case version
    case viewerSummary
    case views
    case allowlistedConfigURLs = "allowlistedConfigUrls"
    case allowlistedPanelURLs = "allowlistedPanelUrls"
  }
}
