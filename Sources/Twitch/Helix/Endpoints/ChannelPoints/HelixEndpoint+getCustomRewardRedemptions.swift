import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets redemptions for a custom Channel Points reward.
  ///
  /// With a user access token, requires `channel:read:redemptions` or
  /// `channel:manage:redemptions`. The broadcaster ID must match the token’s user. Only
  /// the client ID that created the reward can retrieve its redemptions. Reward
  /// management is limited to rewards created by the same client ID.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-custom-reward-redemption
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - rewardID: The identifier of the reward.
  ///   - broadcasterID: The broadcaster’s Twitch user ID; `nil` uses the executing
  ///     client’s authenticated user ID.
  ///   - status: The redemption status to retrieve. Required by Twitch when
  ///     `redemptionIDs` is empty.
  ///   - redemptionIDs: The redemption IDs to include in the request. Defaults to `[]`.
  ///   - sort: The order of the returned results.
  ///   - limit: The maximum number of results to request; `nil` uses Twitch’s default.
  ///   - afterCursor: The pagination cursor for the next page; `nil` starts without an
  ///     after cursor.
  ///
  /// - Returns: An endpoint that yields matching items and a pagination cursor when
  ///   executed. The cursor is `nil` when there is no next page.
  public static func getCustomRewardRedemptions(
    rewardID: String,
    broadcasterID: String? = nil,
    status: CustomRewardRedemptionStatus? = nil,
    redemptionIDs: [String] = [],
    sort: CustomRewardRedemptionSort? = nil,
    limit: Int? = nil,
    after afterCursor: String? = nil
  ) -> HelixEndpoint<
    (redemptions: [CustomRewardRedemption], cursor: String?),
    CustomRewardRedemption,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "channel_points/custom_rewards/redemptions",
      queryItems: { credentials in
        [
          ("broadcaster_id", broadcasterID ?? credentials.userID),
          ("reward_id", rewardID),
          ("status", status?.rawValue),
          ("sort", sort?.rawValue),
          ("first", limit.map(String.init)),
          ("after", afterCursor),
        ] + redemptionIDs.map { ("id", $0) }
      },
      makeResponse: { ($0.data, $0.pagination?.cursor) })
  }
}

/// A viewer’s custom Channel Points reward redemption and fulfillment status.
@MemberwiseInit(.public)
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
@MemberwiseInit(.public)
public struct CustomRewardRedemptionReward: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The title shown to viewers.
  public let title: String
  /// The prompt shown when viewers redeem the reward.
  public let prompt: String
  /// The Channel Points required for one redemption of this reward.
  public let cost: Int
}

/// A custom reward redemption’s fulfillment or cancellation state.
public enum CustomRewardRedemptionStatus: String, Codable, Sendable {
  /// The redemption was cancelled and its Channel Points refunded. Encoded as
  /// `"CANCELED"`.
  case cancelled = "CANCELED"
  /// The redemption was fulfilled. Encoded as `"FULFILLED"`.
  case fulfilled = "FULFILLED"
  /// The redemption is waiting to be fulfilled. Encoded as `"UNFULFILLED"`.
  case unfulfilled = "UNFULFILLED"
}

/// The chronological order used to retrieve reward redemptions.
public enum CustomRewardRedemptionSort: String, Codable, Sendable {
  /// Orders results from oldest to newest. Encoded as `"OLDEST"`.
  case oldest = "OLDEST"
  /// Orders results from newest to oldest. Encoded as `"NEWEST"`.
  case newest = "NEWEST"
}
