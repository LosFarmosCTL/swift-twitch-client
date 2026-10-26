import Foundation

extension HelixEndpoint {
  /// Gets a channel’s schedule in iCalendar format.
  ///
  /// Twitch does not require authentication for this resource.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-channel-icalendar
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - broadcasterID: The Twitch user ID of the broadcaster.
  public static func getChannelICalendar(
    broadcasterID: String
  ) -> HelixEndpoint<String, EmptyResponse, HelixEndpointResponseTypes.Raw> {
    .init(
      method: "GET", path: "schedule/icalendar",
      queryItems: { _ in
        [("broadcaster_id", broadcasterID)]
      },
      makeRawResponse: { data in
        guard let calendar = String(data: data, encoding: .utf8) else {
          throw HelixError.parsingResponseFailed(responseData: data)
        }

        return calendar
      })
  }
}
