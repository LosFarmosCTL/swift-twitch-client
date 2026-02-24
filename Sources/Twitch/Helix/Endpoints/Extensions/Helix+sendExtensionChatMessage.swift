import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Void,
  ResponseType == EmptyResponse, HelixResponseType == EmptyResponse
{
  public static func sendExtensionChatMessage(
    in channel: UserID,
    text: String,
    extensionID: String,
    extensionVersion: String
  ) -> Self {
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
