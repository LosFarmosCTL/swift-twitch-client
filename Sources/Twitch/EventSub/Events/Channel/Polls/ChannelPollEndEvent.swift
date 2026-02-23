import Foundation

public struct ChannelPollEndEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let choices: [ChannelPollBeginEvent.PollChoice]
  public let channelPointsVoting: Int?

  public let status: Status
  public let startedAt: Date
  public let endedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case title, choices
    case channelPointsVoting

    case status, startedAt, endedAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
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

  public enum Status: String, Decodable, Sendable {
    case completed, archived, terminated
  }
}
