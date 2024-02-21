import Foundation

extension HelixEndpoint
where Response == ResponseTypes.Array<ContentClassificationLabel> {
  public static func getContentClassificationLabels(locale: String? = "en-US") -> Self {
    let queryItems = self.makeQueryItems(("locale", locale))

    return .init(
      method: "GET", path: "content_classification_labels", queryItems: queryItems)
  }
}

public struct ContentClassificationLabel: Decodable {
  let id: String
  let description: String
  let name: String
}
