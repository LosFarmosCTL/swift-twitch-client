import Foundation

extension HelixEndpoint {
  public static func sendExtensionChatMessage(
    in channel: String,
    text: String,
    extensionID: String,
    extensionVersion: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void, > {
    .init(
      method: "POST", path: "extensions/chat",
      queryItems: { _ in
        [
          ("broadcaster_id", channel)
        ]
      },
      body: { _ in
        SendExtensionChatMessageRequestBody(
          text: text,
          extensionID: extensionID,
          extensionVersion: extensionVersion)
      })
  }
}

private struct SendExtensionChatMessageRequestBody: Encodable, Sendable {
  let text: String
  let extensionID: String
  let extensionVersion: String
}
