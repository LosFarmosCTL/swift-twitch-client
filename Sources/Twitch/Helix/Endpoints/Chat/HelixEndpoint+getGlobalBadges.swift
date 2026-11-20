import Foundation

extension HelixEndpoint {
  /// Gets Twitch’s global chat badge sets.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-global-chat-badges
  /// ) for request limits and account requirements.
  public static func getGlobalBadges()
    -> HelixEndpoint<[BadgeSet]>
  {
    .init(
      method: "GET", path: "chat/badges/global",
      authentication: .either, responseType: BadgeSet.self, makeResponse: { $0.data })
  }
}
