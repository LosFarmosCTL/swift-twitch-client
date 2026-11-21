import Foundation

/// An EventSub notification delivered when a channel prediction ends.
public struct ChannelPredictionEndEvent: Event {
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
  public let outcomes: [ChannelPredictionBeginEvent.Outcome]
  /// The identifier of the winning outcome, or `nil` when the prediction was canceled.
  public let winningOutcomeID: String?

  /// Whether the prediction was resolved or canceled.
  public let status: Status
  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended.
  public let endedAt: Date

  /// Creates a `ChannelPredictionEndEvent` value.
  public init(
    id: String,
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    title: String,
    outcomes: [ChannelPredictionBeginEvent.Outcome] = [],
    winningOutcomeID: String? = nil,
    status: Status,
    startedAt: Date,
    endedAt: Date
  ) {
    self.id = id
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.title = title
    self.outcomes = outcomes
    self.winningOutcomeID = winningOutcomeID
    self.status = status
    self.startedAt = startedAt
    self.endedAt = endedAt
  }

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case winningOutcomeID = "winningOutcomeId"
    case outcomes
    case status
    case startedAt
    case endedAt
  }

  /// Whether the prediction was resolved or canceled, preserving unfamiliar values in
  /// `rawValue`.
  public struct Status: RawRepresentable, Decodable, Sendable, Hashable {
    /// The exact status string supplied by Twitch or the caller.
    public let rawValue: String

    /// Creates a prediction status from any raw string.
    public init(rawValue: String) { self.rawValue = rawValue }

    /// Decodes a prediction status from a single string.
    public init(from decoder: Decoder) throws {
      self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }

    /// The prediction has a declared winning outcome.
    public static let resolved = Self(rawValue: "resolved")
    /// The operation was cancelled. Encoded as `"canceled"`.
    public static let cancelled = Self(rawValue: "canceled")
  }
}
