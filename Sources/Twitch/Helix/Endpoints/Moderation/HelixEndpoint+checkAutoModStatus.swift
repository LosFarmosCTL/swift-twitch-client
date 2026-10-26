import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Checks messages against a channel’s AutoMod settings.
  ///
  /// With a user access token, requires `moderation:read`. App tokens have additional
  /// grant requirements described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#check-automod-status
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - messages: The message IDs and text to check with AutoMod.
  public static func checkAutoModStatus(messages: (id: String, message: String)...)
    -> HelixEndpoint<[AutoModStatus], AutoModStatus, HelixEndpointResponseTypes.Normal>
  {
    return self.checkAutoModStatus(messages: messages)
  }

  /// Checks messages against a channel’s AutoMod settings.
  ///
  /// With a user access token, requires `moderation:read`. App tokens have additional
  /// grant requirements described in the reference.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#check-automod-status
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `broadcaster_id`.
  ///
  /// - Parameters:
  ///   - messages: The message IDs and text to check with AutoMod.
  public static func checkAutoModStatus(messages: [(id: String, message: String)])
    -> HelixEndpoint<[AutoModStatus], AutoModStatus, HelixEndpointResponseTypes.Normal>
  {
    .init(
      method: "POST", path: "moderation/enforcements/status",
      queryItems: { credentials in
        [("broadcaster_id", credentials.userID)]
      },
      body: { _ in
        [
          "data": messages.map {
            ["msg_id": $0.id, "msg_text": $0.message]
          }
        ]
      },
      makeResponse: { $0.data })
  }
}

/// The AutoMod verdict for a submitted message identifier.
@MemberwiseInit(.public)
public struct AutoModStatus: Decodable, Sendable {
  /// The identifier of the message.
  public let messageID: String
  /// Whether AutoMod permits the message.
  public let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case messageID = "msgId"
    case isPermitted
  }
}
