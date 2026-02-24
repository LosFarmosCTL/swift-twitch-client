import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == HypeTrainStatus, HelixResponseType == HypeTrainStatus
{
  public static func getHypeTrainStatus(for broadcasterID: String? = nil) -> Self {
    return .init(
      method: "GET", path: "hypetrain/status",
      queryItems: { auth in
        [("broadcaster_id", broadcasterID ?? auth.userID)]
      },
      makeResponse: { response in
        guard let status = response.data.first else {
          throw HelixError.noDataInResponse(responseData: response.rawData)
        }

        return status
      })
  }
}

public struct HypeTrainStatus: Decodable, Sendable {
  public let current: HypeTrainCurrent?
  public let allTimeHigh: HypeTrainRecord?
  public let sharedAllTimeHigh: HypeTrainRecord?
}

public struct HypeTrainCurrent: Decodable, Sendable {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

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
    case broadcasterName = "broadcasterUserName"

    case level, total, progress, goal
    case topContributions
    case sharedTrainParticipants
    case startedAt, expiresAt
    case type
    case isSharedTrain
  }
}

public struct HypeTrainRecord: Decodable, Sendable {
  public let level: Int
  public let total: Int
  public let achievedAt: Date
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

public struct HypeTrainParticipant: Decodable, Sendable {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"
  }
}

public enum HypeTrainType: String, Codable, Sendable {
  case regular, treasure
  case goldenKappa = "golden_kappa"
}
