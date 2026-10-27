import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets metadata for an extension release.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Supply the signed JWT as `TwitchCredentials.accessToken` and the extension’s client ID
  /// as `clientID`. The client sends the JWT as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - version: The extension release version; `nil` requests the latest released
  ///     version. Specify a version for an unreleased extension; otherwise Twitch returns
  ///     an empty list and execution throws.
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

/// A Twitch extension’s configuration, capabilities, views, and release metadata.
@MemberwiseInit(.public)
public struct Extension: Decodable, Sendable {
  /// The name of the author.
  public let authorName: String
  /// Whether Bits are enabled for this resource.
  public let bitsEnabled: Bool
  /// Whether the extension can be installed.
  public let canInstall: Bool
  /// Where the extension’s configuration interface is hosted.
  public let configurationLocation: ExtensionConfigurationLocation
  /// The descriptive text supplied by Twitch, when provided.
  public let description: String?
  /// The URL for eula tos, when provided.
  public let eulaTOSURL: String?
  /// Whether the extension supports chat.
  public let hasChatSupport: Bool
  /// The URL for icon.
  public let iconURL: String
  /// The icon URLs, when provided.
  public let iconURLs: [String: String]?
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The URL for privacy policy, when provided.
  public let privacyPolicyURL: String?
  /// Whether the extension requests identity linking.
  public let requestIdentityLink: Bool
  /// The extension screenshot URLs, when provided.
  public let screenshotURLs: [String]?
  /// The extension version’s development, review, or release state.
  public let state: ExtensionState
  /// Whether the extension optionally supports subscriptions.
  public let subscriptionsSupportLevel: ExtensionSubscriptionSupportLevel
  /// The summary details, when provided.
  public let summary: String?
  /// The extension developer’s support email address, when provided.
  public let supportEmail: String?
  /// The extension’s release version.
  public let version: String
  /// The viewer-facing summary, when provided.
  public let viewerSummary: String?
  /// The extension view configurations, when provided.
  public let views: ExtensionViews?
  /// The allowed configuration URLs, when provided.
  public let allowlistedConfigURLs: [String]?
  /// The allowed panel URLs, when provided.
  public let allowlistedPanelURLs: [String]?

  /// The extension’s mobile, panel, video overlay, and component view configurations.
  @MemberwiseInit(.public)
  public struct ExtensionViews: Decodable, Sendable {
    /// The mobile view settings, when provided.
    public let mobile: ExtensionView?
    /// The panel extension slots, when provided.
    public let panel: ExtensionPanelView?
    /// The video overlay settings, when provided.
    public let videoOverlay: ExtensionView?
    /// The component extension slots, when provided.
    public let component: ExtensionComponentView?
  }

  /// A mobile or overlay view’s entry URL and permission to link to external content.
  @MemberwiseInit(.public)
  public struct ExtensionView: Decodable, Sendable {
    /// The URL for viewer.
    public let viewerURL: String
    /// Whether the extension may link to external content, when provided.
    public let canLinkExternalContent: Bool?

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case canLinkExternalContent
    }
  }

  /// A panel view’s entry URL, pixel height, and external-link permission.
  @MemberwiseInit(.public)
  public struct ExtensionPanelView: Decodable, Sendable {
    /// The URL for viewer.
    public let viewerURL: String
    /// The height in pixels.
    public let height: Int
    /// Whether the extension may link to external content.
    public let canLinkExternalContent: Bool

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case height
      case canLinkExternalContent
    }
  }

  /// A video component’s entry URL, aspect ratio, and sizing behavior.
  @MemberwiseInit(.public)
  public struct ExtensionComponentView: Decodable, Sendable {
    /// The URL for viewer.
    public let viewerURL: String
    /// The horizontal component of the aspect ratio, when provided.
    public let aspectRatioX: Int?
    /// The vertical component of the aspect ratio, when provided.
    public let aspectRatioY: Int?
    /// Whether the extension view scales automatically, when provided.
    public let autoscale: Bool?
    /// The base width in pixels used when autoscaling; ignored when `autoscale` is false.
    public let scalePixels: Int?
    /// The height as a percentage of the maximum component height, from 1 to 100.
    public let targetHeight: Int?
    /// Whether the extension may link to external content, when provided.
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

  /// Where the extension’s broadcaster configuration interface is hosted.
  public enum ExtensionConfigurationLocation: String, Decodable, Sendable {
    /// The configuration interface is hosted by Twitch.
    case hosted
    /// The extension uses a custom configuration interface.
    case custom
    /// No value or classification applies.
    case none
  }

  /// The extension version’s development, review, approval, or release state.
  public enum ExtensionState: String, Decodable, Sendable {
    /// Twitch approved the extension. Encoded as `"Approved"`.
    case approved = "Approved"
    /// The extension’s assets have been uploaded. Encoded as `"AssetsUploaded"`.
    case assetsUploaded = "AssetsUploaded"
    /// The extension has been deleted. Encoded as `"Deleted"`.
    case deleted = "Deleted"
    /// The extension version is deprecated. Encoded as `"Deprecated"`.
    case deprecated = "Deprecated"
    /// The extension is undergoing review. Encoded as `"InReview"`.
    case inReview = "InReview"
    /// The extension is being tested. Encoded as `"InTest"`.
    case inTest = "InTest"
    /// The extension requires further action from its developer. Encoded as
    /// `"PendingAction"`.
    case pendingAction = "PendingAction"
    /// The extension was rejected. Encoded as `"Rejected"`.
    case rejected = "Rejected"
    /// The extension version has been released. Encoded as `"Released"`.
    case released = "Released"
  }

  /// Whether the extension can optionally use subscription features.
  public enum ExtensionSubscriptionSupportLevel: String, Decodable, Sendable {
    /// No value or classification applies.
    case none
    /// The extension can optionally support subscriptions.
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
