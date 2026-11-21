import Foundation

extension HelixEndpoint {
  /// Gets redemptions for a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:read:redemptions` or
  /// `channel:manage:redemptions`. The broadcaster ID must match the token’s user. Only
  /// the client ID that created the reward can retrieve its redemptions. Reward
  /// management is limited to rewards created by the same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/channel-points/#get-custom-reward-redemption
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - rewardID: The identifier of the reward.
  ///   - status: The redemption status to retrieve. Required by Twitch when
  ///     `redemptionIDs` is empty.
  ///   - redemptionIDs: The redemption IDs to include in the request. Defaults to `[]`.
  ///   - sort: The order of the returned results.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - cursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getCustomRewardRedemptions(
    rewardID: String,
    status: CustomRewardRedemptionStatus? = nil,
    redemptionIDs: [String] = [],
    sort: CustomRewardRedemptionSort? = nil,
    limit: Int? = nil,
    after cursor: String? = nil
  ) -> HelixEndpoint<CustomRewardRedemptionsResponse> {
    .init(
      method: "GET", path: "channel_points/custom_rewards/redemptions",
      authentication: .user,
      queryItems: { credentials in
        [
          ("broadcaster_id", try credentials.requireUserID(parameter: "broadcaster_id")),
          ("reward_id", rewardID),
          ("status", status?.rawValue),
          ("sort", sort?.rawValue),
          ("first", limit.map(String.init)),
          ("after", cursor),
        ] + redemptionIDs.map { ("id", $0) }
      },
      responseType: CustomRewardRedemption.self,
      makeResponse: {
        CustomRewardRedemptionsResponse(
          redemptions: $0.data, cursor: $0.pagination?.cursor)
      })
  }
}

/// A viewer’s custom Channel Points reward redemption and fulfillment status.
public struct CustomRewardRedemption: Decodable, Sendable {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The identifier assigned by Twitch.
  public let id: String
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String

  /// The text entered by the user when redeeming the reward.
  public let userInput: String
  /// Whether the redemption is pending, fulfilled, or canceled.
  public let status: CustomRewardRedemptionStatus
  /// The time the reward was redeemed.
  public let redeemedAt: Date
  /// The reward details.
  public let reward: CustomRewardRedemptionReward

  /// Creates a `CustomRewardRedemption` value.
  public init(
    broadcasterID: String,
    broadcasterLogin: String,
    broadcasterDisplayName: String,
    id: String,
    userID: String,
    userLogin: String,
    userDisplayName: String,
    userInput: String,
    status: CustomRewardRedemptionStatus,
    redeemedAt: Date,
    reward: CustomRewardRedemptionReward
  ) {
    self.broadcasterID = broadcasterID
    self.broadcasterLogin = broadcasterLogin
    self.broadcasterDisplayName = broadcasterDisplayName
    self.id = id
    self.userID = userID
    self.userLogin = userLogin
    self.userDisplayName = userDisplayName
    self.userInput = userInput
    self.status = status
    self.redeemedAt = redeemedAt
    self.reward = reward
  }

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterId"
    case broadcasterLogin
    case broadcasterDisplayName = "broadcasterName"
    case id
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case userInput
    case status
    case redeemedAt
    case reward
  }
}

/// The identity and details of the reward that was redeemed.
public struct CustomRewardRedemptionReward: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The prompt shown when viewers redeem the reward.
  public let prompt: String
  /// The Channel Points required for one redemption of this reward.
  public let cost: Int

  /// Creates a `CustomRewardRedemptionReward` value.
  public init(
    id: String,
    title: String,
    prompt: String,
    cost: Int
  ) {
    self.id = id
    self.title = title
    self.prompt = prompt
    self.cost = cost
  }
}

/// A custom reward redemption’s fulfillment or cancellation state, preserving unfamiliar
/// values in `rawValue`.
public struct CustomRewardRedemptionStatus: RawRepresentable, Codable, Sendable, Hashable {
  /// The exact status string supplied by Twitch or the caller.
  public let rawValue: String

  /// Creates a redemption status from any raw string.
  public init(rawValue: String) { self.rawValue = rawValue }

  /// Decodes a redemption status from a single string.
  public init(from decoder: Decoder) throws {
    self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
  }

  /// Encodes this redemption status as its raw wire string.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }

  /// The redemption was cancelled and its Channel Points refunded. Encoded as
  /// `"CANCELED"`.
  public static let cancelled = Self(rawValue: "CANCELED")
  /// The redemption was fulfilled. Encoded as `"FULFILLED"`.
  public static let fulfilled = Self(rawValue: "FULFILLED")
  /// The redemption is waiting to be fulfilled. Encoded as `"UNFULFILLED"`.
  public static let unfulfilled = Self(rawValue: "UNFULFILLED")
}

/// The chronological order used to retrieve reward redemptions.
public enum CustomRewardRedemptionSort: String, Sendable, Equatable, Hashable {
  /// Orders results from oldest to newest. Encoded as `"OLDEST"`.
  case oldest = "OLDEST"
  /// Orders results from newest to oldest. Encoded as `"NEWEST"`.
  case newest = "NEWEST"
}

/// A page of custom reward redemptions.
public struct CustomRewardRedemptionsResponse: Sendable {
  /// The redemptions on this page.
  public let redemptions: [CustomRewardRedemption]
  /// The next-page cursor, if Twitch returned one.
  public let cursor: String?

  /// Creates a `CustomRewardRedemptionsResponse` value.
  public init(
    redemptions: [CustomRewardRedemption] = [],
    cursor: String? = nil
  ) {
    self.redemptions = redemptions
    self.cursor = cursor
  }
}
