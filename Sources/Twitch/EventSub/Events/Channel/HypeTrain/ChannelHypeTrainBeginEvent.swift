import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a Hype Train begins.
@MemberwiseInit(.public)
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

  /// The largest Hype Train contributions.
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

  /// The regular, Treasure, and Golden Kappa categories of Hype Train.
  public enum HypeTrainType: String, Codable, Sendable {
    /// A regular Hype Train.
    case regular
    /// A Treasure Train.
    case treasure
    /// A Golden Kappa Hype Train. Encoded as `"golden_kappa"`.
    case goldenKappa = "golden_kappa"
  }

  /// The account identity of a channel participating in a shared Hype Train.
  @MemberwiseInit(.public)
  public struct Broadcaster: Decodable, Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s login name.
    public let userLogin: String
    /// The user’s display name.
    public let userDisplayName: String

    enum CodingKeys: String, CodingKey {
      case userID = "broadcasterUserId"
      case userLogin = "broadcasterUserLogin"
      case userDisplayName = "broadcasterUserName"
    }
  }

  /// A leading contributor’s identity, contribution category, and points total.
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
}
