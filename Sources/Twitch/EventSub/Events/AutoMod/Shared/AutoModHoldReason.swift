/// The filtering category, blocked term, or blocked link that caused a message hold.
public enum AutoModHoldReason: Sendable {
  /// AutoMod matched a filtering category; includes its level and text boundaries.
  case autoMod(AutoMod)
  /// The message matched blocked terms; includes the terms and their text boundaries.
  case blockedTerm(BlockedTerm)
  /// The message matched a blocked link; includes its matching text boundaries.
  case blockedLink(BlockedTerm)
  /// Twitch’s `"unknown"` reason or an unfamiliar reason, preserved as sent.
  case unknown(String)

  /// The filtering category, severity level, and text ranges responsible for a hold.
  public struct AutoMod: Decodable, Sendable {
    /// The name of the AutoMod filtering category that caught the message.
    public let category: String
    /// The AutoMod filtering severity level that caught the message. Level 1 is the most severe.
    public let level: Int
    /// The locations of held content within the message.
    public let boundaries: [Boundary]

    /// Creates an `AutoMod` value.
    public init(
      category: String,
      level: Int,
      boundaries: [Boundary] = []
    ) {
      self.category = category
      self.level = level
      self.boundaries = boundaries
    }
  }

  /// The blocked terms found in a message and the text ranges they matched.
  public struct BlockedTerm: Decodable, Sendable {
    /// The blocked terms found in the message, with their owners and text ranges.
    public let terms: [Term]

    /// Creates a `BlockedTerm` value.
    public init(
      terms: [Term] = []
    ) {
      self.terms = terms
    }

    enum CodingKeys: String, CodingKey {
      case terms = "termsFound"
    }

    /// A matched blocked term’s ID, text range, and owning broadcaster.
    public struct Term: Decodable, Sendable {
      /// The identifier of the term.
      public let termID: String
      /// The location of the held content within the message.
      public let boundary: Boundary
      /// The Twitch user ID of the owner broadcaster.
      public let ownerBroadcasterID: String
      /// The login name of the owner broadcaster.
      public let ownerBroadcasterLogin: String
      /// The display name of the owner broadcaster.
      public let ownerBroadcasterDisplayName: String

      /// Creates a `Term` value.
      public init(
        termID: String,
        boundary: Boundary,
        ownerBroadcasterID: String,
        ownerBroadcasterLogin: String,
        ownerBroadcasterDisplayName: String
      ) {
        self.termID = termID
        self.boundary = boundary
        self.ownerBroadcasterID = ownerBroadcasterID
        self.ownerBroadcasterLogin = ownerBroadcasterLogin
        self.ownerBroadcasterDisplayName = ownerBroadcasterDisplayName
      }

      enum CodingKeys: String, CodingKey {
        case termID = "termId"
        case boundary
        case ownerBroadcasterID = "ownerBroadcasterUserId"
        case ownerBroadcasterLogin = "ownerBroadcasterUserLogin"
        case ownerBroadcasterDisplayName = "ownerBroadcasterUserName"
      }
    }
  }

  /// An inclusive range of held text, expressed as zero-based message offsets.
  public struct Boundary: Decodable, Sendable {
    /// The zero-based, inclusive start offset of the held text within the message.
    public let startPosition: Int
    /// The zero-based, inclusive end offset of the held text within the message.
    public let endPosition: Int

    /// Creates a `Boundary` value.
    public init(
      startPosition: Int,
      endPosition: Int
    ) {
      self.startPosition = startPosition
      self.endPosition = endPosition
    }

    enum CodingKeys: String, CodingKey {
      case startPosition = "startPos"
      case endPosition = "endPos"
    }
  }

  enum CodingKeys: String, CodingKey {
    case reason
    case autoMod = "automod"
    case blockedTerm
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let rawReason = try container.decode(String.self, forKey: .reason)
    guard let reason = HoldReason(rawValue: rawReason) else {
      self = .unknown(rawReason)
      return
    }

    switch reason {
    case .autoMod:
      let autoModReason = try container.decode(
        AutoModHoldReason.AutoMod.self, forKey: .autoMod)

      self = .autoMod(autoModReason)
    case .blockedTerm:
      let blockedTermReason = try container.decode(
        AutoModHoldReason.BlockedTerm.self, forKey: .blockedTerm)

      self = .blockedTerm(blockedTermReason)
    case .blockedLink:
      let blockedLinkReason = try container.decode(
        AutoModHoldReason.BlockedTerm.self, forKey: .blockedTerm)

      self = .blockedLink(blockedLinkReason)
    }
  }

  private enum HoldReason: String, Decodable, Sendable {
    case autoMod = "automod"
    case blockedTerm = "blocked_term"
    case blockedLink = "blocked_link"
  }
}
