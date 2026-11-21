import Foundation

extension HelixEndpoint {
  /// Gets the authenticated broadcaster’s current Hype Train and historical records.
  ///
  /// With a user access token, requires `channel:read:hype_train`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/hype-train/#get-hype-train-status
  /// ) for request limits and account requirements.
  public static func getHypeTrainStatus()
    -> HelixEndpoint<HypeTrainStatus>
  {
    .init(
      method: "GET", path: "hypetrain/status",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id"))
        ]
      },
      responseType: HypeTrainStatus.self,
      makeResponse: { response in
        let status = try response.requireFirst()

        return status
      })
  }
}

/// A channel’s current Hype Train and historical records.
public struct HypeTrainStatus: Decodable, Sendable {
  /// The current progress toward the goal, when provided.
  public let current: HypeTrainCurrent?
  /// The all-time Hype Train record, when provided.
  public let allTimeHigh: HypeTrainRecord?
  /// The all-time shared Hype Train record, when provided.
  public let sharedAllTimeHigh: HypeTrainRecord?

  /// Creates a `HypeTrainStatus` value.
  public init(
    current: HypeTrainCurrent? = nil,
    allTimeHigh: HypeTrainRecord? = nil,
    sharedAllTimeHigh: HypeTrainRecord? = nil
  ) {
    self.current = current
    self.allTimeHigh = allTimeHigh
    self.sharedAllTimeHigh = sharedAllTimeHigh
  }
}

/// An active Hype Train’s progress, participants, and leading contributions.
public struct HypeTrainCurrent: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The current level.
  public let level: Int
  /// The cumulative contribution points earned during this Hype Train.
  public let total: Int
  /// The progress reported for the current level.
  public let progress: Int
  /// The goal required to complete this level.
  public let goal: Int

  /// The largest Hype Train contributions.
  public let topContributions: [HypeTrainContribution]
  /// The channels participating in the shared Hype Train, when provided.
  public let sharedTrainParticipants: [HypeTrainParticipant]?

  /// The time the activity started.
  public let startedAt: Date
  /// The time the resource expires.
  public let expiresAt: Date

  /// The Hype Train category reported by Twitch.
  public let type: HypeTrainType
  /// Whether the Hype Train spans multiple channels.
  public let isSharedTrain: Bool

  /// Creates a `HypeTrainCurrent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    level: Int,
    total: Int,
    progress: Int,
    goal: Int,
    topContributions: [HypeTrainContribution] = [],
    sharedTrainParticipants: [HypeTrainParticipant]? = nil,
    startedAt: Date,
    expiresAt: Date,
    type: HypeTrainType,
    isSharedTrain: Bool
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.level = level
    self.total = total
    self.progress = progress
    self.goal = goal
    self.topContributions = topContributions
    self.sharedTrainParticipants = sharedTrainParticipants
    self.startedAt = startedAt
    self.expiresAt = expiresAt
    self.type = type
    self.isSharedTrain = isSharedTrain
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case level
    case total
    case progress
    case goal
    case topContributions
    case sharedTrainParticipants
    case startedAt
    case expiresAt
    case type
    case isSharedTrain
  }
}

/// A historical Hype Train record and when it was achieved.
public struct HypeTrainRecord: Decodable, Sendable {
  /// The current level.
  public let level: Int
  /// The cumulative contribution points earned during this Hype Train.
  public let total: Int
  /// The time the record was achieved.
  public let achievedAt: Date

  /// Creates a `HypeTrainRecord` value.
  public init(
    level: Int,
    total: Int,
    achievedAt: Date
  ) {
    self.level = level
    self.total = total
    self.achievedAt = achievedAt
  }
}

/// A user’s contribution to a Hype Train.
public struct HypeTrainContribution: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The contribution category, such as Bits or subscriptions.
  public let type: ContributionType
  /// The contributor’s points from this contribution category during the Hype Train.
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

/// A channel participating in a shared Hype Train.
public struct HypeTrainParticipant: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// Creates a `HypeTrainParticipant` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
  }
}

/// The regular, Treasure, and Golden Kappa categories of Hype Train, preserving
/// unfamiliar values in `rawValue`.
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
}
