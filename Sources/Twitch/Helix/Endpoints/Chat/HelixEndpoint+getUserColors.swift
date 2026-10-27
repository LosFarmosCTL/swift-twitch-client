import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets the chat name colors of the requested users.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-user-chat-color
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - userIDs: The user IDs to include in the request.
  public static func getUserColors(
    of userIDs: [String]
  ) -> HelixEndpoint<[UserColor], UserColor, HelixEndpointResponseTypes.Normal> {
    .init(
      method: "GET", path: "chat/color",
      authentication: .either,
      queryItems: { _ in
        userIDs.map { ("user_id", $0) }
      }, makeResponse: { $0.data })
  }
}

/// A user’s chat display color.
@MemberwiseInit(.public)
public struct UserColor: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s login name.
  public let userLogin: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The color reported by Twitch.
  public let color: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userLogin
    case userDisplayName = "userName"
    case color
  }
}
