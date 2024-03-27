import Foundation

extension HelixEndpoint
where
  EndpointResponseType == HelixEndpointResponseTypes.Normal,
  ResponseType == [ContentClassificationLabel],
  HelixResponseType == ContentClassificationLabel
{
  public static func getContentClassificationLabels(locale: String? = "en-US") -> Self {
    return .init(
      method: "GET", path: "content_classification_labels",
      queryItems: { _ in
        [("locale", locale)]
      }, makeResponse: { $0.data })
  }
}

public struct ContentClassificationLabel: Decodable {
  public let id: String
  public let description: String
  public let name: String
}
