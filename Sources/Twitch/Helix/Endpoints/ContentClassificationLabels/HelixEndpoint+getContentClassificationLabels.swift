import Foundation

extension HelixEndpoint {
  public static func getContentClassificationLabels(
    locale: String? = "en-US"
  ) -> HelixEndpoint<
    [ContentClassificationLabel], ContentClassificationLabel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "content_classification_labels",
      queryItems: { _ in
        [("locale", locale)]
      }, makeResponse: { $0.data })
  }
}

public struct ContentClassificationLabel: Decodable, Sendable {
  public let id: String
  public let description: String
  public let name: String
}
