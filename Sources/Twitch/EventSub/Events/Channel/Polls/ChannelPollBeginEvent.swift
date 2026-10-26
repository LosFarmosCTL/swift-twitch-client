import Foundation
import MemberwiseInit

public typealias ChannelPollProgressEvent = ChannelPollBeginEvent

@MemberwiseInit(.public)
public struct ChannelPollBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let title: String
  public let choices: [PollChoice]
  public let channelPointsVoting: Int?

  public let startedAt: Date
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

  @MemberwiseInit(.public)
  public struct PollChoice: Decodable, Sendable {
    public let id: String
    public let title: String
    public let channelPointsVotes: Int?
    public let votes: Int?
  }

  struct ChannelPointsVoting: Decodable, Sendable {
    let isEnabled: Bool
    let amountPerVote: Int
  }
}
