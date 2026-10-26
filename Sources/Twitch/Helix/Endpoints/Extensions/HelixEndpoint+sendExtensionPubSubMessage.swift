import Foundation

extension HelixEndpoint {
  /// Sends a PubSub message to an extension’s viewers.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-extension-pubsub-message
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - target: The recipients of the extension message.
  ///   - message: The text to send.
  ///   - broadcasterID: The Twitch user ID of the broadcaster, when provided.
  ///   - isGlobalBroadcast: Whether to send to all extension channels.
  public static func sendExtensionPubSubMessage(
    target: [ExtensionPubSubMessageTarget],
    message: String,
    broadcasterID: String? = nil,
    isGlobalBroadcast: Bool? = nil
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "POST", path: "extensions/pubsub",
      body: { _ in
        SendExtensionPubSubMessageRequestBody(
          target: target,
          broadcasterID: broadcasterID,
          isGlobalBroadcast: isGlobalBroadcast,
          message: message)
      })
  }
}

/// The viewers or channels that should receive an extension PubSub message.
public enum ExtensionPubSubMessageTarget: Sendable {
  /// Sends the message to viewers in the broadcaster’s channel.
  case broadcast
  /// Sends the message to all channels using the extension.
  case global
  /// Sends the message privately to the viewer identified by the associated user ID.
  case whisper(String)
}

extension ExtensionPubSubMessageTarget: Encodable {
  /// Encodes this value using Twitch’s wire representation.
  ///
  /// - Throws: An error if the encoder cannot encode the value.
  ///
  /// - Parameters:
  ///   - encoder: The encoder that receives the Twitch wire representation.
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .broadcast:
      try container.encode("broadcast")
    case .global:
      try container.encode("global")
    case .whisper(let userID):
      try container.encode("whisper-\(userID)")
    }
  }
}

private struct SendExtensionPubSubMessageRequestBody: Encodable, Sendable {
  let target: [ExtensionPubSubMessageTarget]
  let broadcasterID: String?
  let isGlobalBroadcast: Bool?
  let message: String
}
