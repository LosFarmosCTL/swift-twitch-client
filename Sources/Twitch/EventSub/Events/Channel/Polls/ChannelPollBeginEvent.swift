import Foundation
import MemberwiseInit

/// The payload for channel poll progress notifications.
///
/// Uses the same payload fields as ``ChannelPollBeginEvent``.
public typealias ChannelPollProgressEvent = ChannelPollBeginEvent

/// An EventSub notification delivered when a channel poll begins.
@MemberwiseInit(.public)
public struct ChannelPollBeginEvent: Event {
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
  /// The poll choices.
  public let choices: [PollChoice]
  /// Channel Points charged per additional vote; `nil` means Channel Points voting is
  /// disabled.
  public let channelPointsVoting: Int?

  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity is scheduled to end.
  public let endsAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case choices
    case channelPointsVoting
    case startedAt
    case endsAt
  }

  /// Decodes a poll, mapping disabled Channel Points voting to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    title = try container.decode(String.self, forKey: .title)
    choices = try container.decode([PollChoice].self, forKey: .choices)
    startedAt = try container.decode(Date.self, forKey: .startedAt)
    endsAt = try container.decode(Date.self, forKey: .endsAt)

    let channelPointsVoting = try container.decodeIfPresent(
      ChannelPointsVoting.self, forKey: .channelPointsVoting)
    self.channelPointsVoting =
      if let channelPointsVoting, channelPointsVoting.isEnabled {
        channelPointsVoting.amountPerVote
      } else {
        nil
      }
  }

  /// A poll choice’s identity and title, with vote counts when provided.
  @MemberwiseInit(.public)
  public struct PollChoice: Decodable, Sendable {
    /// The identifier assigned by Twitch.
    public let id: String
    /// The title shown to viewers.
    public let title: String
    /// The number of votes purchased using Channel Points, when provided.
    public let channelPointsVotes: Int?
    /// The number of votes for this choice, when provided.
    public let votes: Int?
  }

  struct ChannelPointsVoting: Decodable, Sendable {
    let isEnabled: Bool
    let amountPerVote: Int
  }
}
