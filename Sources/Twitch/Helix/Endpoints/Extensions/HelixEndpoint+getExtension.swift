import Foundation

extension HelixEndpoint {
  /// Gets metadata for an extension release.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Use `TwitchCredentials.extensionJWT(token:clientID:)` with the signed JWT and the
  /// extension’s client ID. The client sends it as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/extensions/#get-extensions
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - extensionID: The identifier of the extension.
  ///   - version: The extension release version; `nil` requests the latest released
  ///     version. Specify a version for an unreleased extension; otherwise Twitch returns
  ///     HTTP 404.
  public static func getExtension(
    extensionID: String,
    version: String? = nil
  ) -> HelixEndpoint<Extension> {
    .init(
      method: "GET", path: "extensions",
      authentication: .extensionJWT,
      queryItems: { _ in
        [
          ("extension_id", extensionID),
          ("extension_version", version),
        ]
      },
      responseType: Extension.self,
      makeResponse: { response in
        let extensionInfo = try response.requireFirst()

        return extensionInfo
      })
  }
}

/// A Twitch extension’s configuration, capabilities, views, and release metadata.
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
  /// The URL of the extension's EULA or terms of service, when provided.
  public let eulaTOSURL: String?
  /// Whether the extension supports chat.
  public let hasChatSupport: Bool
  /// The URL of the extension's default icon.
  public let iconURL: String
  /// The icon URLs, when provided.
  public let iconURLs: [String: String]?
  /// The identifier assigned by Twitch.
  public let id: String
  /// The name supplied by Twitch.
  public let name: String
  /// The URL of the extension's privacy policy, when provided.
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

  /// Creates an `Extension` value.
  public init(
    authorName: String,
    bitsEnabled: Bool,
    canInstall: Bool,
    configurationLocation: ExtensionConfigurationLocation,
    description: String? = nil,
    eulaTOSURL: String? = nil,
    hasChatSupport: Bool,
    iconURL: String,
    iconURLs: [String: String]? = nil,
    id: String,
    name: String,
    privacyPolicyURL: String? = nil,
    requestIdentityLink: Bool,
    screenshotURLs: [String]? = nil,
    state: ExtensionState,
    subscriptionsSupportLevel: ExtensionSubscriptionSupportLevel,
    summary: String? = nil,
    supportEmail: String? = nil,
    version: String,
    viewerSummary: String? = nil,
    views: ExtensionViews? = nil,
    allowlistedConfigURLs: [String]? = nil,
    allowlistedPanelURLs: [String]? = nil
  ) {
    self.authorName = authorName
    self.bitsEnabled = bitsEnabled
    self.canInstall = canInstall
    self.configurationLocation = configurationLocation
    self.description = description
    self.eulaTOSURL = eulaTOSURL
    self.hasChatSupport = hasChatSupport
    self.iconURL = iconURL
    self.iconURLs = iconURLs
    self.id = id
    self.name = name
    self.privacyPolicyURL = privacyPolicyURL
    self.requestIdentityLink = requestIdentityLink
    self.screenshotURLs = screenshotURLs
    self.state = state
    self.subscriptionsSupportLevel = subscriptionsSupportLevel
    self.summary = summary
    self.supportEmail = supportEmail
    self.version = version
    self.viewerSummary = viewerSummary
    self.views = views
    self.allowlistedConfigURLs = allowlistedConfigURLs
    self.allowlistedPanelURLs = allowlistedPanelURLs
  }

  /// The extension’s mobile, panel, video overlay, and component view configurations.
  public struct ExtensionViews: Decodable, Sendable {
    /// The view shown when configuring the extension in the Extension Manager.
    public let config: ExtensionView?
    /// The broadcaster’s live configuration view, when supported.
    public let liveConfig: ExtensionView?
    /// The mobile view settings, when provided.
    public let mobile: ExtensionView?
    /// The panel extension slots, when provided.
    public let panel: ExtensionPanelView?
    /// The video overlay settings, when provided.
    public let videoOverlay: ExtensionView?
    /// The component extension slots, when provided.
    public let component: ExtensionComponentView?

    /// Creates an `ExtensionViews` value.
    public init(
      config: ExtensionView? = nil,
      liveConfig: ExtensionView? = nil,
      mobile: ExtensionView? = nil,
      panel: ExtensionPanelView? = nil,
      videoOverlay: ExtensionView? = nil,
      component: ExtensionComponentView? = nil
    ) {
      self.config = config
      self.liveConfig = liveConfig
      self.mobile = mobile
      self.panel = panel
      self.videoOverlay = videoOverlay
      self.component = component
    }
  }

  /// A mobile or overlay view’s entry URL and permission to link to external content.
  public struct ExtensionView: Decodable, Sendable {
    /// The viewer entry URL for this extension view.
    public let viewerURL: String
    /// Whether the extension may link to external content, when provided.
    public let canLinkExternalContent: Bool?

    /// Creates an `ExtensionView` value.
    public init(
      viewerURL: String,
      canLinkExternalContent: Bool? = nil
    ) {
      self.viewerURL = viewerURL
      self.canLinkExternalContent = canLinkExternalContent
    }

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case canLinkExternalContent
    }
  }

  /// A panel view’s entry URL, pixel height, and external-link permission.
  public struct ExtensionPanelView: Decodable, Sendable {
    /// The viewer entry URL for this extension view.
    public let viewerURL: String
    /// The height in pixels.
    public let height: Int
    /// Whether the extension may link to external content.
    public let canLinkExternalContent: Bool

    /// Creates an `ExtensionPanelView` value.
    public init(
      viewerURL: String,
      height: Int,
      canLinkExternalContent: Bool
    ) {
      self.viewerURL = viewerURL
      self.height = height
      self.canLinkExternalContent = canLinkExternalContent
    }

    enum CodingKeys: String, CodingKey {
      case viewerURL = "viewerUrl"
      case height
      case canLinkExternalContent
    }
  }

  /// A video component’s entry URL, aspect ratio, and sizing behavior.
  public struct ExtensionComponentView: Decodable, Sendable {
    /// The viewer entry URL for this extension view.
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

    /// Creates an `ExtensionComponentView` value.
    public init(
      viewerURL: String,
      aspectRatioX: Int? = nil,
      aspectRatioY: Int? = nil,
      autoscale: Bool? = nil,
      scalePixels: Int? = nil,
      targetHeight: Int? = nil,
      canLinkExternalContent: Bool? = nil
    ) {
      self.viewerURL = viewerURL
      self.aspectRatioX = aspectRatioX
      self.aspectRatioY = aspectRatioY
      self.autoscale = autoscale
      self.scalePixels = scalePixels
      self.targetHeight = targetHeight
      self.canLinkExternalContent = canLinkExternalContent
    }

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

  /// Where the extension’s broadcaster configuration interface is hosted, preserving
  /// unfamiliar values in `rawValue`.
  public struct ExtensionConfigurationLocation: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact configuration location string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a configuration location from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a configuration location from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The configuration interface is hosted by Twitch.
    public static let hosted = Self(rawValue: "hosted")
    /// The extension uses a custom configuration interface.
    public static let custom = Self(rawValue: "custom")
    /// No value or classification applies.
    public static let none = Self(rawValue: "none")
  }

  /// The extension version’s development, review, approval, or release state, preserving
  /// unfamiliar values in `rawValue`.
  public struct ExtensionState: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact extension state string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates an extension state from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes an extension state from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Twitch approved the extension. Encoded as `"Approved"`.
    public static let approved = Self(rawValue: "Approved")
    /// The extension’s assets have been uploaded. Encoded as `"Assets Uploaded"`.
    public static let assetsUploaded = Self(rawValue: "Assets Uploaded")
    /// The extension has been deleted. Encoded as `"Deleted"`.
    public static let deleted = Self(rawValue: "Deleted")
    /// The extension version is deprecated. Encoded as `"Deprecated"`.
    public static let deprecated = Self(rawValue: "Deprecated")
    /// The extension is undergoing review. Encoded as `"In Review"`.
    public static let inReview = Self(rawValue: "In Review")
    /// The extension is being tested. Encoded as `"Testing"`.
    public static let inTest = Self(rawValue: "Testing")
    /// The extension requires further action from its developer. Encoded as
    /// `"Pending Action"`.
    public static let pendingAction = Self(rawValue: "Pending Action")
    /// The extension was rejected. Encoded as `"Rejected"`.
    public static let rejected = Self(rawValue: "Rejected")
    /// The extension version has been released. Encoded as `"Released"`.
    public static let released = Self(rawValue: "Released")
  }

  /// Whether the extension can optionally use subscription features, preserving
  /// unfamiliar values in `rawValue`.
  public struct ExtensionSubscriptionSupportLevel:
    RawRepresentable, Decodable, Sendable, Hashable
  {
    /// The exact subscription support level string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a subscription support level from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a subscription support level from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// No value or classification applies.
    public static let none = Self(rawValue: "none")
    /// The extension can optionally support subscriptions.
    public static let optional = Self(rawValue: "optional")
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
