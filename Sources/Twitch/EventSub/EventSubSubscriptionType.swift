public struct EventSubSubscriptionType {
  let type: String
  let version: String
  let condition: [String: String]
}

extension EventSubSubscriptionType {
  public static func channelUpdate(broadcasterID: UserID, version: String = "2") -> Self {
    .init(
      type: "channel.update", version: version,
      condition: ["broadcaster_user_id": broadcasterID])
  }

}
