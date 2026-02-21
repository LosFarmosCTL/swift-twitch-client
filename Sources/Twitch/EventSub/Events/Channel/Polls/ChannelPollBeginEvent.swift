import Foundation

public typealias ChannelPollProgressEvent = ChannelPollBeginEvent

public struct ChannelPollBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let title: String
  public let choices: [PollChoice]
  public let channelPointsVoting: Int?

  public let startedAt: Date
  public let endsAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case title, choices
    case channelPointsVoting

    case startedAt, endsAt
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
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

  public struct PollChoice: Decodable, Sendable {
    public let id: String
    public let title: String
    public let channelPointsVotes: Int?
    public let votes: Int?
  }

  struct ChannelPointsVoting: Decodable, Sendable {
    public let isEnabled: Bool
    public let amountPerVote: Int
  }
}
