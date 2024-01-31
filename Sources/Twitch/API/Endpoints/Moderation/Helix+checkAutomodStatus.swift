import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func checkAutomodStatus(messages: (msgId: String, msg: String)...) async throws
    -> [AutomodStatus]
  { return try await self.checkAutomodStatus(messageList: messages) }

  public func checkAutomodStatus(messageList: [(msgId: String, msg: String)]) async throws
    -> [AutomodStatus]
  {
    let queryItems = self.makeQueryItems(("broadcaster_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<AutomodStatus>?) = try await self.request(
      .get("moderation/enforcements/status"), with: queryItems,
      jsonBody: ["data": messageList.map { ["msg_id": $0.msgId, "msg_text": $0.msg] }])

    guard let result else { throw HelixError.invalidResponse(rawResponse: rawResponse) }

    return result.data
  }
}

public struct AutomodStatus: Decodable {
  let msgId: String
  let isPermitted: Bool

  enum CodingKeys: String, CodingKey {
    case msgId = "msg_id"
    case isPermitted = "is_permitted"
  }
}
