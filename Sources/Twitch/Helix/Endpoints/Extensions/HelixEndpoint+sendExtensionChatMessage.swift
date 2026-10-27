import Foundation

extension HelixEndpoint {
  /// Sends a chat message on behalf of an extension.
  ///
  /// Twitch requires an Extension Backend Service JWT with the `external` role. See the
  /// reference for the required claims and signing rules.
  /// Supply the signed JWT as `TwitchCredentials.accessToken` and the extension’s client ID
  /// as `clientID`. The client sends the JWT as a Bearer token; it does not sign JWTs.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#send-extension-chat-message
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  ///   - text: The text content.
  ///   - extensionID: The identifier of the extension.
  ///   - extensionVersion: The extension release version.
  public static func sendExtensionChatMessage(
    in broadcasterID: String,
    text: String,
    extensionID: String,
    extensionVersion: String
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void, > {
    .init(
      method: "POST", path: "extensions/chat",
      queryItems: { _ in
        [
          ("broadcaster_id", broadcasterID)
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
