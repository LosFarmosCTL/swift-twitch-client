import Foundation
import MemberwiseInit

/// An EventSub notification delivered when a channel poll ends.
@MemberwiseInit(.public)
public struct ChannelPollEndEvent: Event {
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
  public let choices: [ChannelPollBeginEvent.PollChoice]
  /// Channel Points charged per additional vote; `nil` means Channel Points voting is
  /// disabled.
  public let channelPointsVoting: Int?

  /// Whether the poll completed, was terminated, or was archived.
  public let status: Status
  /// The time the activity started.
  public let startedAt: Date
  /// The time the activity ended.
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case title
    case choices
    case channelPointsVoting
    case status
    case startedAt
    case endedAt
  }

  /// Decodes a poll result, mapping disabled Channel Points voting to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)
    title = try container.decode(String.self, forKey: .title)
    choices = try container.decode(
      [ChannelPollBeginEvent.PollChoice].self, forKey: .choices)
    status = try container.decode(Status.self, forKey: .status)
    startedAt = try container.decode(Date.self, forKey: .startedAt)
    endedAt = try container.decode(Date.self, forKey: .endedAt)

    let channelPointsVoting = try container.decodeIfPresent(
      ChannelPollBeginEvent.ChannelPointsVoting.self,
      forKey: .channelPointsVoting)
    self.channelPointsVoting =
      if let channelPointsVoting, channelPointsVoting.isEnabled {
        channelPointsVoting.amountPerVote
      } else {
        nil
      }

  }

  /// Whether the poll completed, was terminated, or was archived.
  public enum Status: String, Decodable, Sendable {
    /// The poll completed normally.
    case completed
    /// The poll has been archived.
    case archived
    /// The poll ended before its scheduled completion.
    case terminated
  }
}
