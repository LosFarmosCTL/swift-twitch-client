import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets a channel’s current Hype Train and historical records.
  ///
  /// With a user access token, requires `channel:read:hype_train`.
  ///
  /// For user-token requests, the broadcaster must be the token’s user.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-hype-train-status
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  public static func getHypeTrainStatus(for broadcasterID: String? = nil)
    -> HelixEndpoint<HypeTrainStatus, HypeTrainStatus, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "hypetrain/status",
      authentication: .user,
      queryItems: { credentials in
        [
          (
            "broadcaster_id",
            try credentials.resolveUserID(broadcasterID, parameter: "broadcaster_id")
          )
        ]
      },
      makeResponse: { response in
        let status = try response.requireFirst()

        return status
      })
  }
}

/// A channel’s current Hype Train and historical records.
@MemberwiseInit(.public)
public struct HypeTrainStatus: Decodable, Sendable {
  /// The current progress toward the goal, when provided.
  public let current: HypeTrainCurrent?
  /// The all-time Hype Train record, when provided.
  public let allTimeHigh: HypeTrainRecord?
  /// The all-time shared Hype Train record, when provided.
  public let sharedAllTimeHigh: HypeTrainRecord?
}

/// An active Hype Train’s progress, participants, and leading contributions.
@MemberwiseInit(.public)
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
@MemberwiseInit(.public)
public struct HypeTrainRecord: Decodable, Sendable {
  /// The current level.
  public let level: Int
  /// The cumulative contribution points earned during this Hype Train.
  public let total: Int
  /// The time the record was achieved.
  public let achievedAt: Date
}

/// A user’s contribution to a Hype Train.
@MemberwiseInit(.public)
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

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case type
    case total
  }

  /// Whether Hype Train points came from Bits, subscriptions, or another source.
  public enum ContributionType: String, Codable, Sendable {
    /// A contribution made with Bits.
    case bits
    /// A contribution made with a subscription.
    case subscription
    /// A contribution of another kind.
    case other
  }
}

/// A channel participating in a shared Hype Train.
@MemberwiseInit(.public)
public struct HypeTrainParticipant: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
  }
}

/// The regular, Treasure, and Golden Kappa categories of Hype Train.
public enum HypeTrainType: String, Codable, Sendable {
  /// A regular Hype Train.
  case regular
  /// A Treasure Train.
  case treasure
  /// A Golden Kappa Hype Train. Encoded as `"golden_kappa"`.
  case goldenKappa = "golden_kappa"
}
