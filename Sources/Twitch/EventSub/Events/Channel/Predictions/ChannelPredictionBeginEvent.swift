import Foundation
import MemberwiseInit

/// The payload for channel prediction progress notifications.
///
/// Uses the same payload fields as ``ChannelPredictionBeginEvent``.
public typealias ChannelPredictionProgressEvent = ChannelPredictionBeginEvent

/// An EventSub notification delivered when a channel prediction begins.
@MemberwiseInit(.public)
public struct ChannelPredictionBeginEvent: Event {
  /// The identifier assigned by Twitch.
  public let id: String

  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The title shown to viewers.
  public let title: String
  /// The prediction outcomes.
  public let outcomes: [Outcome]
  /// The time the activity started.
  public let startedAt: Date
  /// The time the prediction is scheduled to lock.
  public let locksAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case outcomes
    case startedAt
    case locksAt
  }

  /// A prediction outcome’s identity, display color, and any participation totals.
  @MemberwiseInit(.public)
  public struct Outcome: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The title shown to viewers.
    public let title: String
    /// The color reported by Twitch.
    public let color: Color

    /// The number of viewers who selected this outcome; absent in prediction-begin
    /// payloads.
    public let users: Int?
    /// The number of Channel Points, when provided.
    public let channelPoints: Int?
    /// The top predictors for this outcome, when provided.
    public let topPredictors: [TopPredictor]?

    /// The display color assigned to a prediction outcome.
    public enum Color: String, Decodable, Sendable {
      /// The pink prediction outcome.
      case pink
      /// The blue color option.
      case blue
    }

    /// A leading viewer’s identity, wager, and any winnings for this outcome.
    @MemberwiseInit(.public)
    public struct TopPredictor: Decodable, Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s login name.
      public let userLogin: String
      /// The user’s display name.
      public let userDisplayName: String

      /// The Channel Points spent on the prediction outcome.
      public let channelPointsUsed: Int
      /// The Channel Points awarded for the prediction outcome, when provided.
      public let channelPointsWon: Int?

      enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case userLogin
        case userDisplayName = "userName"
        case channelPointsUsed
        case channelPointsWon
      }
    }
  }

}
