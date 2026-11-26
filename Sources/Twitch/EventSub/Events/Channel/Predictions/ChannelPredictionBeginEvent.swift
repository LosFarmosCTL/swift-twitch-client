import Foundation

/// The payload for channel prediction progress notifications.
///
/// Uses the same payload fields as ``ChannelPredictionBeginEvent``.
public typealias ChannelPredictionProgressEvent = ChannelPredictionBeginEvent

/// An EventSub notification delivered when a channel prediction begins.
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

  /// Creates a `ChannelPredictionBeginEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    outcomes: [Outcome] = [],
    startedAt: Date,
    locksAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.outcomes = outcomes
    self.startedAt = startedAt
    self.locksAt = locksAt
  }

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
  public struct Outcome: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The title shown to viewers.
    public let title: String
    /// The outcome color. Two-outcome predictions use blue and pink. Predictions
    /// with more outcomes use blue for all of them.
    public let color: Color

    /// The number of viewers who selected this outcome, including viewers who
    /// participated without spending points. Omitted when a prediction begins.
    public let users: Int?
    /// The total Channel Points used on this outcome. Omitted when a prediction begins.
    public let channelPoints: Int?
    /// The viewers who spent the most Channel Points on this outcome, highest first.
    /// Entries can include viewers who spent zero points. Omitted when a prediction begins.
    public let topPredictors: [TopPredictor]?

    /// Creates an `Outcome` value.
    public init(
      id: String,
      title: String,
      color: Color,
      users: Int? = nil,
      channelPoints: Int? = nil,
      topPredictors: [TopPredictor]? = nil
    ) {
      self.id = id
      self.title = title
      self.color = color
      self.users = users
      self.channelPoints = channelPoints
      self.topPredictors = topPredictors
    }

    /// The display color assigned to a prediction outcome, preserving unfamiliar values
    /// in `rawValue`.
    public struct Color: RawRepresentable, Decodable, Sendable, Hashable {
      /// The exact color string supplied by Twitch or the caller.
      public let rawValue: String

      /// Creates an outcome color from any raw string.
      public init(rawValue: String) { self.rawValue = rawValue }

      /// Decodes an outcome color from a single string.
      public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
      }

      /// The pink prediction outcome.
      public static let pink = Self(rawValue: "pink")
      /// The blue color option.
      public static let blue = Self(rawValue: "blue")
    }

    /// A leading viewer’s identity, wager, and any winnings for this outcome.
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

      /// Creates a `TopPredictor` value.
      public init(
        userID: String,
        userLogin: String,
        userDisplayName: String,
        channelPointsUsed: Int,
        channelPointsWon: Int? = nil
      ) {
        self.userID = userID
        self.userLogin = userLogin
        self.userDisplayName = userDisplayName
        self.channelPointsUsed = channelPointsUsed
        self.channelPointsWon = channelPointsWon
      }

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
