import Foundation
import MemberwiseInit

extension HelixEndpoint {
  public static func getHypeTrainStatus(for broadcasterID: String? = nil)
    -> HelixEndpoint<HypeTrainStatus, HypeTrainStatus, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "GET", path: "hypetrain/status",
      queryItems: { credentials in
        [("broadcaster_id", broadcasterID ?? credentials.userID)]
      },
      makeResponse: { response in
        let status = try response.requireFirst()

        return status
      })
  }
}

@MemberwiseInit(.public)
public struct HypeTrainStatus: Decodable, Sendable {
  public let current: HypeTrainCurrent?
  public let allTimeHigh: HypeTrainRecord?
  public let sharedAllTimeHigh: HypeTrainRecord?
}

@MemberwiseInit(.public)
public struct HypeTrainCurrent: Decodable, Sendable {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let level: Int
  public let total: Int
  public let progress: Int
  public let goal: Int

  public let topContributions: [HypeTrainContribution]
  public let sharedTrainParticipants: [HypeTrainParticipant]?

  public let startedAt: Date
  public let expiresAt: Date

  public let type: HypeTrainType
  public let isSharedTrain: Bool

  enum CodingKeys: String, CodingKey {
    case id
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case level
    case total
    case progress
    case goal
    case topContributions
    case sharedTrainParticipants
    case startedAt
    case expiresAt
    case type
    case isSharedTrain
  }
}

@MemberwiseInit(.public)
public struct HypeTrainRecord: Decodable, Sendable {
  public let level: Int
  public let total: Int
  public let achievedAt: Date
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

@MemberwiseInit(.public)
public struct HypeTrainParticipant: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
  }
}

public enum HypeTrainType: String, Codable, Sendable {
  case regular, treasure
  case goldenKappa = "golden_kappa"
}
