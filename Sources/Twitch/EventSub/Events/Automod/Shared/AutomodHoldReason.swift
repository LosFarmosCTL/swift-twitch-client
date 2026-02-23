public enum AutomodHoldReason: Sendable {
  case automod(Automod)
  case blockedTerm(BlockedTerm)

  public struct Automod: Decodable, Sendable {
    public let category: String
    public let level: Int
    public let boundaries: [Boundary]
  }

  public struct BlockedTerm: Decodable, Sendable {
    public let terms: [Term]

    enum CodingKeys: String, CodingKey {
      case terms = "termsFound"
    }

    public struct Term: Decodable, Sendable {
      public let termID: String
      public let boundary: Boundary
      public let ownerBroadcasterID: String
      public let ownerBroadcasterLogin: String
      public let ownerBroadcasterName: String

      enum CodingKeys: String, CodingKey {
        case termID = "termId"
        case boundary
        case ownerBroadcasterID = "ownerBroadcasterUserId"
        case ownerBroadcasterLogin = "ownerBroadcasterUserLogin"
        case ownerBroadcasterName = "ownerBroadcasterUserName"
      }
    }
  }

  public struct Boundary: Decodable, Sendable {
    public let startPosition: Int
    public let endPosition: Int

    enum CodingKeys: String, CodingKey {
      case startPosition = "startPos"
      case endPosition = "endPos"
    }
  }

  enum CodingKeys: String, CodingKey {
    case reason, automod, blockedTerm
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let reason = try container.decode(HoldReason.self, forKey: .reason)
    switch reason {
    case .automod:
      let automodReason = try container.decode(
        AutomodHoldReason.Automod.self, forKey: .automod)

      self = .automod(automodReason)
    case .blockedTerm:
      let blockedTermReason = try container.decode(
        AutomodHoldReason.BlockedTerm.self, forKey: .blockedTerm)

      self = .blockedTerm(blockedTermReason)
    }
  }

  private enum HoldReason: String, Decodable, Sendable {
    case automod = "automod"
    case blockedTerm = "blocked_term"
  }
}
