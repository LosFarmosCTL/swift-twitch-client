import Foundation
import TwitchIRC

extension ChatBadge {
  internal init(eventSub value: ChannelChatMessageEvent.Badge) {
    self.init(setID: value.setID, version: value.id, info: value.info)
  }
}

extension ChatMessage {
  internal init(eventSub event: ChannelChatMessageEvent) {
    let actionPrefix = "\u{1}ACTION ".unicodeScalars
    let rawText = event.message.text.unicodeScalars
    let isAction = rawText.starts(with: actionPrefix) && rawText.last == "\u{1}"
    let prefixLength = isAction ? actionPrefix.count : 0
    let text = isAction ? String(rawText.dropFirst(prefixLength).dropLast()) : event.message.text
    self.init(
      id: event.messageID,
      author: ChatUser(
        id: event.chatterID, login: event.chatterLogin,
        displayName: event.chatterDisplayName),
      text: text, isAction: isAction,
      emotes: Self.eventSubEmotes(in: event.message, text: text, actionPrefixLength: prefixLength),
      color: event.color,
      badges: event.badges.map(ChatBadge.init(eventSub:)),
      replyToMessageID: event.reply?.parentID,
      isIntroduction: event.messageType == .userIntro,
      sourceChannelID: event.sourceBroadcasterID, sourceMessageID: event.sourceMessageID,
      sourceBadges: event.sourceBadges?.map(ChatBadge.init(eventSub:)),
      isSourceOnly: event.isSourceOnly, details: .eventSub(event))
  }

  private static func eventSubEmotes(
    in message: ChannelChatMessageEvent.Message, text: String, actionPrefixLength: Int
  ) -> [ChatEmote] {
    let fragmentScalars = message.fragments.lazy.flatMap { $0.text.unicodeScalars }
    let fragmentsAreFramed =
      actionPrefixLength > 0 && fragmentScalars.elementsEqual(message.text.unicodeScalars)
    let textScalars = text.unicodeScalars
    guard fragmentsAreFramed || fragmentScalars.elementsEqual(textScalars) else { return [] }

    // Count from the start of the displayed text, skipping any framing in the fragments.
    var offset = fragmentsAreFramed ? -actionPrefixLength : 0
    let length = textScalars.count
    var emotes: [ChatEmote] = []
    for fragment in message.fragments {
      let start = offset
      offset += fragment.text.unicodeScalars.count
      guard case .emote(let emote) = fragment.type, offset <= length,
        let range = MessageTextRange(unicodeScalarOffsets: start..<offset)
      else { continue }
      emotes.append(ChatEmote(id: emote.id, name: fragment.text, range: range))
    }
    return emotes
  }
}

extension ChatNotification {
  internal init(eventSub event: ChannelChatNotificationEvent) {
    let author: ChatUser?
    switch event.chatter {
    case .anonymous: author = nil
    case .chatter(let chatter):
      author = ChatUser(
        id: chatter.userID, login: chatter.userLogin, displayName: chatter.userDisplayName
      )
    }
    self.init(
      kind: event.noticeType.chatKind, id: event.messageID, author: author,
      text: event.message.text.chatNonempty, systemMessage: event.systemMessage.chatNonempty,
      sourceChannelID: event.sourceBroadcasterID, sourceMessageID: event.sourceMessageID,
      isSourceOnly: event.isSourceOnly,
      details: .eventSub(event))
  }
}

extension ChatRoomSettings {
  internal init(eventSub event: ChannelChatSettingsUpdateEvent) {
    self.init(
      emoteOnly: event.emoteMode, subscribersOnly: event.subscriberMode,
      uniqueMessages: event.uniqueChatMode, followersOnly: event.followerMode,
      slowMode: event.slowMode, isKnown: true)
  }
}

extension ChannelChatNotificationEvent.NoticeType {
  internal var chatKind: String {
    switch self {
    case .sub: "sub"
    case .resub: "resub"
    case .subGift: "sub_gift"
    case .communitySubGift: "community_sub_gift"
    case .giftPaidUpgrade: "gift_paid_upgrade"
    case .primePaidUpgrade: "prime_paid_upgrade"
    case .payItForward: "pay_it_forward"
    case .raid: "raid"
    case .unraid: "unraid"
    case .announcement: "announcement"
    case .bitsBadgeTier: "bits_badge_tier"
    case .charityDonation: "charity_donation"
    case .giftedDropsSummary: "gifted_drops_summary"
    case .watchStreak: "watch_streak"
    case .modiversary: "modiversary"
    case .sharedChatSub: "shared_chat_sub"
    case .sharedChatResub: "shared_chat_resub"
    case .sharedChatSubGift: "shared_chat_sub_gift"
    case .sharedChatCommunitySubGift: "shared_chat_community_sub_gift"
    case .sharedChatGiftPaidUpgrade: "shared_chat_gift_paid_upgrade"
    case .sharedChatPrimePaidUpgrade: "shared_chat_prime_paid_upgrade"
    case .sharedChatPayItForward: "shared_chat_pay_it_forward"
    case .sharedChatRaid: "shared_chat_raid"
    case .sharedChatUnraid: "shared_chat_unraid"
    case .sharedChatAnnouncement: "shared_chat_announcement"
    case .sharedChatBitsBadgeTier: "shared_chat_bits_badge_tier"
    case .sharedChatCharityDonation: "shared_chat_charity_donation"
    case .sharedChatGiftedDropsSummary: "shared_chat_gifted_drops_summary"
    case .sharedChatModiversary: "shared_chat_modiversary"
    case .unknown(let kind): kind
    }
  }
}

extension ChatModeration.Action {
  internal init(eventSub action: ChannelModerateEvent.Action, referenceDate: Date = Date()) {
    switch action {
    case .ban(let user), .sharedChatBan(let user):
      self = .ban(
        user: ChatUser(
          id: user.userID, login: user.userLogin,
          displayName: user.userDisplayName), reason: user.reason)

    case .timeout(let user), .sharedChatTimeout(let user):
      let seconds = max(1, Int64(ceil(user.expiresAt.timeIntervalSince(referenceDate))))
      self = .timeout(
        user: ChatUser(
          id: user.userID, login: user.userLogin,
          displayName: user.userDisplayName), until: user.expiresAt,
        duration: .seconds(seconds), reason: user.reason)

    case .unban(let user), .sharedChatUnban(let user):
      self = .unban(chatModerationUser(user))

    case .untimeout(let user), .sharedChatUntimeout(let user):
      self = .untimeout(chatModerationUser(user))

    default: self = .eventSub(action)
    }
  }
}

private func chatModerationUser(_ user: ChannelModerateEvent.Action.User) -> ChatUser {
  ChatUser(id: user.userID, login: user.userLogin, displayName: user.userDisplayName)
}
