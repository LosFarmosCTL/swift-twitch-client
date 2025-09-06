import Foundation

// events contain identical shape of data
public typealias ChannelPointsCustomRewardUpdateEvent = ChannelPointsCustomRewardAddEvent
public typealias ChannelPointsCustomRewardRemoveEvent = ChannelPointsCustomRewardAddEvent

public struct ChannelPointsCustomRewardAddEvent: Event {
  public let id: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let isEnabled: Bool
  public let isPaused: Bool
  public let isInStock: Bool

  public let title: String
  public let cost: Int
  public let prompt: String

  public let isUserInputRequired: Bool
  public let shouldRedemptionsSkipRequestQueue: Bool

  public let maxPerStream: Int?
  public let maxPerUserPerStream: Int?

  public let backgroundColor: String

  public let image: RewardImage?
  public let defaultImage: RewardImage?
  public let globalCooldown: Duration?

  public let cooldownExpiresAt: Date?
  public let redemptionsRedeemedCurrentStream: Int?

  enum CodingKeys: String, CodingKey {
    case id

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case isEnabled, isPaused, isInStock
    case title, cost, prompt
    case isUserInputRequired, shouldRedemptionsSkipRequestQueue
    case maxPerStream, maxPerUserPerStream
    case backgroundColor, image, defaultImage
    case globalCooldown, cooldownExpiresAt
    case redemptionsRedeemedCurrentStream
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    id = try container.decode(String.self, forKey: .id)
    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterName = try container.decode(String.self, forKey: .broadcasterName)
    isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
    isPaused = try container.decode(Bool.self, forKey: .isPaused)
    isInStock = try container.decode(Bool.self, forKey: .isInStock)
    title = try container.decode(String.self, forKey: .title)
    cost = try container.decode(Int.self, forKey: .cost)
    prompt = try container.decode(String.self, forKey: .prompt)
    isUserInputRequired = try container.decode(Bool.self, forKey: .isUserInputRequired)
    shouldRedemptionsSkipRequestQueue = try container.decode(
      Bool.self, forKey: .shouldRedemptionsSkipRequestQueue)
    backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
    image = try container.decodeIfPresent(RewardImage.self, forKey: .image)
    defaultImage = try container.decodeIfPresent(RewardImage.self, forKey: .defaultImage)
    cooldownExpiresAt = try container.decodeIfPresent(
      Date.self, forKey: .cooldownExpiresAt)
    redemptionsRedeemedCurrentStream = try container.decodeIfPresent(
      Int.self, forKey: .redemptionsRedeemedCurrentStream)

    let maxPerStream = try container.decodeIfPresent(
      MaxPerStream.self, forKey: .maxPerStream)
    let maxPerUserPerStream = try container.decodeIfPresent(
      MaxPerUserPerStream.self, forKey: .maxPerUserPerStream)
    let globalCooldown = try container.decodeIfPresent(
      GlobalCooldown.self, forKey: .globalCooldown)

    self.maxPerStream = maxPerStream?.value
    self.maxPerUserPerStream = maxPerUserPerStream?.value
    self.globalCooldown =
      if let globalCooldown { .seconds(globalCooldown.seconds) } else { nil }
  }

  struct MaxPerStream: Decodable, Sendable {
    public let isEnabled: Bool
    public let value: Int
  }

  struct MaxPerUserPerStream: Decodable, Sendable {
    public let isEnabled: Bool
    public let value: Int
  }

  struct GlobalCooldown: Decodable, Sendable {
    public let isEnabled: Bool
    public let seconds: Int
  }

  public struct RewardImage: Decodable, Sendable {
    public let url1x: String
    public let url2x: String
    public let url4x: String

    enum CodingKeys: String, CodingKey {
      case url1x = "url1X"
      case url2x = "url2X"
      case url4x = "url4X"
    }
  }
}
