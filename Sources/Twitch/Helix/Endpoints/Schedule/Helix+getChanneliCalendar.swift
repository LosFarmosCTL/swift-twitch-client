import Foundation

extension HelixEndpoint {
  public static func getChanneliCalendar(
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
