import Foundation

/// An EventSub notification delivered when a Hype Train begins.
public struct ChannelHypeTrainBeginEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The cumulative contribution points earned during this Hype Train.
  public let total: Int
  /// The progress reported for the current level.
  public let progress: Int
  /// The goal required to complete this level.
  public let goal: Int

  /// The current level.
  public let level: Int
  /// The highest level achieved across all Hype Trains.
  public let allTimeHighLevel: Int
  /// The highest contribution total achieved across all Hype Trains.
  public let allTimeHighTotal: Int

  /// The top contributor per type among the contributions that started the train.
  /// For a shared train, only contributions in this broadcaster’s channel count.
  public let topContributions: [HypeTrainContribution]

  /// The time the activity started.
  public let startedAt: Date
  /// The time the resource expires.
  public let expiresAt: Date

  /// The channels participating in the shared Hype Train, when provided.
  public let sharedTrainParticipants: [Broadcaster]?
  /// Whether the Hype Train spans multiple channels.
  public let isSharedTrain: Bool

  /// The Hype Train category reported by Twitch.
  public let type: HypeTrainType

  /// Creates a `ChannelHypeTrainBeginEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    total: Int,
    progress: Int,
    goal: Int,
    level: Int,
    allTimeHighLevel: Int,
    allTimeHighTotal: Int,
    topContributions: [HypeTrainContribution] = [],
    startedAt: Date,
    expiresAt: Date,
    sharedTrainParticipants: [Broadcaster]? = nil,
    isSharedTrain: Bool,
    type: HypeTrainType
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.total = total
    self.progress = progress
    self.goal = goal
    self.level = level
    self.allTimeHighLevel = allTimeHighLevel
    self.allTimeHighTotal = allTimeHighTotal
    self.topContributions = topContributions
    self.startedAt = startedAt
    self.expiresAt = expiresAt
    self.sharedTrainParticipants = sharedTrainParticipants
    self.isSharedTrain = isSharedTrain
    self.type = type
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case total
    case progress
    case goal
    case level
    case allTimeHighLevel
    case allTimeHighTotal
    case topContributions
    case startedAt
    case expiresAt
    case sharedTrainParticipants
    case isSharedTrain
    case type
  }

  /// The Hype Train category, preserving unfamiliar values in `rawValue`.
  public struct HypeTrainType: RawRepresentable, Codable, Sendable, Hashable {
    /// The exact Hype Train type string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a Hype Train type from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a Hype Train type from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// Encodes this Hype Train type as its raw wire string.
    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }

    /// A regular Hype Train.
    public static let regular = Self(rawValue: "regular")
    /// A Treasure Train.
    public static let treasure = Self(rawValue: "treasure")
    /// A Golden Kappa Hype Train. Encoded as `"golden_kappa"`.
    public static let goldenKappa = Self(rawValue: "golden_kappa")
    /// A Mythic Hype Train. Encoded as `"mythic"`.
    public static let mythic = Self(rawValue: "mythic")
  }

  /// The account identity of a channel participating in a shared Hype Train.
  public struct Broadcaster: Decodable, Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s login name.
    public let userLogin: String
    /// The user’s display name.
    public let userDisplayName: String

    /// Creates a `Broadcaster` value.
    public init(
      userID: String,
      userLogin: String,
      userDisplayName: String
    ) {
      self.userID = userID
      self.userLogin = userLogin
      self.userDisplayName = userDisplayName
    }

    enum CodingKeys: String, CodingKey {
      case userID = "broadcasterUserId"
      case userLogin = "broadcasterUserLogin"
      case userDisplayName = "broadcasterUserName"
    }
  }

  /// A leading contributor’s identity, contribution category, and points total.
  public struct HypeTrainContribution: Decodable, Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s login name.
    public let userLogin: String
    /// The user’s display name.
    public let userDisplayName: String

    /// The contribution category, such as Bits or subscriptions.
    public let type: ContributionType
    /// The contributor’s points for this type. Bits count one point each. Tier 1, 2,
    /// and 3 subscriptions count for 500, 1000, and 2500 points per month, respectively.
    public let total: Int

    /// Creates a `HypeTrainContribution` value.
    public init(
      userID: String,
      userLogin: String,
      userDisplayName: String,
      type: ContributionType,
      total: Int
    ) {
      self.userID = userID
      self.userLogin = userLogin
      self.userDisplayName = userDisplayName
      self.type = type
      self.total = total
    }

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin
      case userDisplayName = "userName"
      case type
      case total
    }

    /// Whether Hype Train points came from Bits, subscriptions, or another source,
    /// preserving unfamiliar values in `rawValue`.
    public struct ContributionType: RawRepresentable, Codable, Sendable, Hashable {
      /// The exact contribution type string supplied by Twitch or the caller.
      public let rawValue: String

      /// Creates a contribution type from any raw string.
      public init(rawValue: String) { self.rawValue = rawValue }

      /// Decodes a contribution type from a single string.
      public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
      }

      /// Encodes this contribution type as its raw wire string.
      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
      }

      /// A contribution made with Bits.
      public static let bits = Self(rawValue: "bits")
      /// A contribution made with a subscription.
      public static let subscription = Self(rawValue: "subscription")
      /// A contribution of another kind.
      public static let other = Self(rawValue: "other")
    }
  }
}
