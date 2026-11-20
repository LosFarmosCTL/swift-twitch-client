import Foundation
import TwitchIRC

extension ChatMessage {
  internal init(irc value: PrivateMessage) {
    self.init(
      id: value.id,
      author: ChatUser(
        id: value.userID.chatNonempty, login: value.userLogin.chatNonempty,
        displayName: value.displayName.chatNonempty), text: value.message,
      color: value.color,
      badges: chatIRCBadges(value.badges, info: value.badgeInfo),
      replyToMessageID: value.replyParent?.id,
      clientNonce: value.clientNonce,
      isFirstMessage: value.firstMessage,
      isReturningChatter: value.returningChatter,
      contentFilterFlags: value.flags.joined(separator: ",").chatNonempty,
      isIntroduction: nil,
      sourceChannelID: value.source?.roomID,
      sourceMessageID: value.source?.id,
      sourceBadges: value.source.map { chatIRCBadges($0.badges, info: $0.badgeInfo) },
      isSourceOnly: value.sourceOnly, details: .irc(value))
  }
}

extension ChatNotification {
  internal init(irc value: UserNotice) {
    let kind: String
    let details: Details
    switch value.kind {
    case .sharedChatNotice(let sourceNotice):
      let sourceKind = sourceNotice?.chatKind ?? value.sourceKind
      kind = sourceKind.map { "shared_chat_" + $0 } ?? "shared_chat_notice"
      details = .ircSharedChat(value)
    default:
      kind = value.kind.chatKind
      details = .irc(value)
    }
    self.init(
      kind: kind, id: value.id.chatNonempty,
      author: ChatUser(
        id: value.userID.chatNonempty, login: value.userLogin.chatNonempty,
        displayName: value.displayName.chatNonempty),
      text: value.message.chatNonempty,
      systemMessage: value.systemMessage.chatNonempty,
      sourceChannelID: value.source?.roomID,
      sourceMessageID: value.source?.id,
      isSourceOnly: nil,
      details: details)
  }
}

extension IncomingMessage {
  internal var chatChannel: String? {
    switch self {
    case .privateMessage(let value): value.channel
    case .userNotice(let value): value.channel
    case .roomState(let value): value.channel
    case .userState(let value): value.channel
    case .clearChat(let value): value.channel
    case .clearMessage(let value): value.channel
    default: nil
    }
  }

  internal var chatTimestamp: Date? {
    switch self {
    case .privateMessage(let value): chatIRCTimestamp(value.timestampMilliseconds)
    case .userNotice(let value): chatIRCTimestamp(value.timestampMilliseconds)
    case .clearChat(let value): chatIRCTimestamp(value.timestampMilliseconds)
    case .clearMessage(let value): chatIRCTimestamp(value.timestampMilliseconds)
    default: nil
    }
  }
}

extension UserNotice.Kind {
  internal var chatKind: String {
    switch self {
    case .sub: "sub"
    case .resub: "resub"
    case .raid: "raid"
    case .unraid: "unraid"
    case .announcement: "announcement"
    case .subGift, .anonSubGift: "sub_gift"
    case .subMysteryGift: "community_sub_gift"
    case .giftPaidUpgrade, .anonGiftPaidUpgrade: "gift_paid_upgrade"
    case .primePaidUpgrade: "prime_paid_upgrade"
    case .communityPayForward, .standardPayForward: "pay_it_forward"
    case .bitsBadgeTier: "bits_badge_tier"
    case .charityDonation: "charity_donation"
    case .rewardGift: "reward_gift"
    case .ritual: "ritual"
    case .midnightSquid: "midnight_squid"
    case .modiversary: "modiversary"
    case .viewerMilestone: "viewer_milestone"
    case .sharedChatNotice: "shared_chat_notice"
    case .unknown(let rawKind): rawKind
    }
  }
}

internal func chatIRCTimestamp(_ milliseconds: UInt?) -> Date? {
  guard let milliseconds, milliseconds > 0 else { return nil }
  return Date(timeIntervalSince1970: Double(milliseconds) / 1000)
}

internal func chatIRCBadges(
  _ badges: [TwitchIRC.Badge], info: [TwitchIRC.BadgeInfo]
) -> [ChatBadge] {
  let info = Dictionary(
    info.map { ($0.setID, $0.value) }, uniquingKeysWith: { _, last in last })

  return badges.map {
    ChatBadge(setID: $0.setID, version: $0.version, info: info[$0.setID])
  }
}

extension String {
  internal var chatNonempty: String? { isEmpty ? nil : self }
}
