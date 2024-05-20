import Foundation

internal struct EventSubRevocation: Decodable {
  let subscriptionID: String
  let status: Status

  enum Status: String, Decodable {
    case authorizationRevoked = "authorization_revoked"
    case userRemoved = "user_removed"
    case versionRemoved = "version_removed"
  }

  struct Subscription: Decodable {
    let id: String
    let status: Status
  }

  enum CodingKeys: CodingKey {
    case subscription
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let subscription = try container.decode(Subscription.self, forKey: .subscription)

    self.status = subscription.status
    self.subscriptionID = subscription.id
  }
}
