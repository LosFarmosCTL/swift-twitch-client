import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getContentClassificationLabels(locale: String? = "en-US") async throws -> (
    [ContentClassificationLabel]
  ) {
    let queryItems = self.makeQueryItems(("locale", locale))

    let (rawResponse, result): (_, HelixData<ContentClassificationLabel>?) =
      try await self.request(.get("content_classification_labels"), with: queryItems)

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return (result.data)
  }
}

public struct ContentClassificationLabel: Decodable {
  let id: String
  let description: String
  let name: String
}
