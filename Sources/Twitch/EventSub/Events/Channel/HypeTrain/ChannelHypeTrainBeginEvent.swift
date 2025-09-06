import Foundation

public struct ChannelHypeTrainBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let total: Int
  public let progress: Int
  public let goal: Int

  public let level: Int
  public let allTimeHighLevel: Int
  public let allTimeHighTotal: Int

  public let topContributions: [HypeTrainContribution]

  public let startedAt: Date
  public let expiresAt: Date

  public let sharedTrainParticipants: [Broadcaster]?
  public let isSharedTrain: Bool

  public let type: HypeTrainType

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case total, progress, goal
    case level, allTimeHighLevel, allTimeHighTotal

    case topContributions

    case startedAt, expiresAt

    case sharedTrainParticipants, isSharedTrain

    case type
  }

  public enum HypeTrainType: String, Codable, Sendable {
    case regular, treasure
    case goldenKappa = "golden_kappa"
  }

  public struct Broadcaster: Decodable, Sendable {
    public let userID: String
    public let userLogin: String
    public let userName: String

    enum CodingKeys: String, CodingKey {
      case userID = "broadcasterUserId"
      case userLogin = "broadcasterUserLogin"
      case userName = "broadcasterUserName"
    }
  }

  public struct HypeTrainContribution: Decodable, Sendable {
    public let userID: String
    public let userLogin: String
    public let userName: String

    public let type: ContributionType
    public let total: Int

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin, userName

      case type, total
    }

    public enum ContributionType: String, Codable, Sendable {
      case bits, subscription, other
    }
  }
}
