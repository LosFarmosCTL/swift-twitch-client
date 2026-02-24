import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func sendExtensionPubSubMessage(
    target: [ExtensionPubSubMessageTarget],
    message: String,
    broadcasterID: UserID? = nil,
    isGlobalBroadcast: Bool? = nil
  ) -> Self {
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

public enum ExtensionPubSubMessageTarget: Sendable {
  case broadcast
  case global
  case whisper(UserID)
}

extension ExtensionPubSubMessageTarget: Encodable {
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
