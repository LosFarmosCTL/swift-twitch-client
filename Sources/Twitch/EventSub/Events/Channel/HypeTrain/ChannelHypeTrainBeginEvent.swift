import Foundation
import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelHypeTrainBeginEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

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

  public enum HypeTrainType: String, Codable, Sendable {
    case regular, treasure
    case goldenKappa = "golden_kappa"
  }

  @MemberwiseInit(.public)
  public struct Broadcaster: Decodable, Sendable {
    public let userID: String
    public let userLogin: String
    public let userDisplayName: String

    enum CodingKeys: String, CodingKey {
      case userID = "broadcasterUserId"
      case userLogin = "broadcasterUserLogin"
      case userDisplayName = "broadcasterUserName"
    }
  }

  @MemberwiseInit(.public)
  public struct HypeTrainContribution: Decodable, Sendable {
    public let userID: String
    public let userLogin: String
    public let userDisplayName: String

    public let type: ContributionType
    public let total: Int

    enum CodingKeys: String, CodingKey {
      case userID = "userId"
      case userLogin
      case userDisplayName = "userName"
      case type
      case total
    }

    public enum ContributionType: String, Codable, Sendable {
      case bits, subscription, other
    }
  }
}
