import Foundation

internal struct EventSubReconnect: Decodable {
  let sessionID: String
  let reconnectURL: URL

  struct Session: Decodable {
    let id: String
    let reconnectURL: URL
    let connectedAt: Date

    enum CodingKeys: String, CodingKey {
      case id
      case reconnectURL = "reconnectUrl"
      case connectedAt
    }
  }

  enum CodingKeys: CodingKey {
    case session
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let session = try container.decode(Session.self, forKey: .session)

    self.sessionID = session.id
    self.reconnectURL = session.reconnectURL
  }
}
