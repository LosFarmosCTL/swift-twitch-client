import Foundation

internal struct EventSubReconnect: Decodable {
  let sessionID: String
  let reconnectURL: URL

  struct Session: Decodable {
    let id: String
    let reconnectUrl: URL
    let connectedAt: Date
  }

  enum CodingKeys: CodingKey {
    case session
  }

  internal init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let session = try container.decode(Session.self, forKey: .session)

    self.sessionID = session.id
    self.reconnectURL = session.reconnectUrl
  }
}
