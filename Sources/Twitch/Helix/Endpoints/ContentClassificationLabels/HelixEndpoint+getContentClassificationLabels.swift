import Foundation
import MemberwiseInit

extension HelixEndpoint {
  /// Gets Twitch’s content classification labels in the requested locale.
  ///
  /// Accepts a user or app access token without an additional endpoint scope.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#get-content-classification-labels
  /// ) for request limits and account requirements.
  ///
  /// - Parameters:
  ///   - locale: The locale used for localized label text. Defaults to `"en-US"`.
  public static func getContentClassificationLabels(
    locale: String? = "en-US"
  ) -> HelixEndpoint<
    [ContentClassificationLabel], ContentClassificationLabel,
    HelixEndpointResponseTypes.Normal
  > {
    .init(
      method: "GET", path: "content_classification_labels",
      authentication: .either,
      queryItems: { _ in
        [("locale", locale)]
      }, makeResponse: { $0.data })
  }
}

/// A localized content classification label available for streams.
@MemberwiseInit(.public)
public struct ContentClassificationLabel: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The descriptive text supplied by Twitch.
  public let description: String
  /// The name supplied by Twitch.
  public let name: String
}
