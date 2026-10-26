import MemberwiseInit

/// An EventSub notification delivered when Twitch emits a chat notification.
@MemberwiseInit(.public)
public struct ChannelChatNotificationEvent: Event {
  /// The Twitch user ID of the broadcaster.
  public let broadcasterID: String
  /// The login name of the broadcaster.
  public let broadcasterLogin: String
  /// The display name of the broadcaster.
  public let broadcasterDisplayName: String

  /// The chatter identity.
  public let chatter: Chatter

  /// The color reported by Twitch.
  public let color: String
  /// The chat badges.
  public let badges: [ChannelChatMessageEvent.Badge]

  /// The identifier of the message.
  public let messageID: String
  /// The message content or explanatory text supplied by Twitch.
  public let message: ChannelChatMessageEvent.Message
  /// The system-generated chat message.
  public let systemMessage: String

  /// The notification category and its associated payload.
  public let noticeType: NoticeType

  /// The Twitch user ID of the source broadcaster, when provided.
  public let sourceBroadcasterID: String?
  /// The login name of the source broadcaster, when provided.
  public let sourceBroadcasterLogin: String?
  /// The display name of the source broadcaster, when provided.
  public let sourceBroadcasterDisplayName: String?
  /// The identifier of the source message, when provided.
  public let sourceMessageID: String?
  /// The badges from the source channel, when provided.
  public let sourceBadges: [ChannelChatMessageEvent.Badge]?

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterDisplayName = "broadcasterUserName"
    case chatterID = "chatterUserId"
    case chatterLogin = "chatterUserLogin"
    case chatterDisplayName = "chatterUserName"
    case chatterIsAnonymous
    case color
    case badges
    case messageID = "messageId"
    case message
    case systemMessage
    case noticeType
    case sub
    case resub
    case subGift
    case communitySubGift
    case giftPaidUpgrade
    case primePaidUpgrade
    case payItForward
    case raid
    case unraid
    case announcement
    case bitsBadgeTier
    case charityDonation
    case giftedDropsSummary
    case sharedChatSub
    case sharedChatResub
    case sharedChatSubGift
    case sharedChatCommunitySubGift
    case sharedChatGiftPaidUpgrade
    case sharedChatPrimePaidUpgrade
    case sharedChatPayItForward
    case sharedChatRaid
    case sharedChatAnnouncement
    case sharedChatBitsBadgeTier
    case sharedChatCharityDonation
    case sharedChatGiftedDropsSummary
    case sourceBroadcasterID = "sourceBroadcasterUserId"
    case sourceBroadcasterLogin = "sourceBroadcasterUserLogin"
    case sourceBroadcasterDisplayName = "sourceBroadcasterUserName"
    case sourceMessageID = "sourceMessageId"
    case sourceBadges
  }

  /// Decodes a chat notification and its notice-specific payload.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    broadcasterID = try container.decode(String.self, forKey: .broadcasterID)
    broadcasterLogin = try container.decode(String.self, forKey: .broadcasterLogin)
    broadcasterDisplayName = try container.decode(
      String.self, forKey: .broadcasterDisplayName)

    chatter = try Chatter(from: decoder)

    color = try container.decode(String.self, forKey: .color)
    badges = try container.decode([ChannelChatMessageEvent.Badge].self, forKey: .badges)

    messageID = try container.decode(String.self, forKey: .messageID)
    message = try container.decode(ChannelChatMessageEvent.Message.self, forKey: .message)
    systemMessage = try container.decode(String.self, forKey: .systemMessage)

    noticeType = try NoticeType(from: decoder)

    sourceBroadcasterID = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterID)
    sourceBroadcasterLogin = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterLogin)
    sourceBroadcasterDisplayName = try container.decodeIfPresent(
      String.self, forKey: .sourceBroadcasterDisplayName)
    sourceMessageID = try container.decodeIfPresent(String.self, forKey: .sourceMessageID)
    sourceBadges = try container.decodeIfPresent(
      [ChannelChatMessageEvent.Badge].self, forKey: .sourceBadges)
  }

  /// The user responsible for a notification, or an indication that they are anonymous.
  public enum Chatter: Sendable {
    /// The user responsible for the notification chose to remain anonymous.
    case anonymous
    /// The identified user responsible for the chat notification.
    case chatter(ChatterInfo)

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      let isAnonymous = try container.decode(Bool.self, forKey: .chatterIsAnonymous)
      if isAnonymous {
        self = .anonymous
      } else {
        let chatterID = try container.decode(String.self, forKey: .chatterID)
        let chatterLogin = try container.decode(String.self, forKey: .chatterLogin)
        let chatterDisplayName = try container.decode(
          String.self, forKey: .chatterDisplayName)
        self = .chatter(
          .init(
            userID: chatterID, userDisplayName: chatterDisplayName,
            userLogin: chatterLogin))
      }
    }

    /// The account identity of the user responsible for a chat notification.
    public struct ChatterInfo: Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The user’s login name.
      public let userLogin: String
    }
  }

  /// The activity reported in chat, with the payload specific to that activity.
  public enum NoticeType: Sendable {
    /// A viewer started a subscription.
    case sub(SubNotice)
    /// A subscriber shared a resubscription message.
    case resub(ResubNotice)
    /// A viewer gifted a subscription to a specified recipient.
    case subGift(SubGiftNotice)
    /// A viewer gifted a batch of subscriptions to the community.
    case communitySubGift(CommunitySubGiftNotice)
    /// A recipient replaced a gifted subscription with a paid subscription.
    case giftPaidUpgrade(GiftPaidUpgradeNotice)
    /// A subscriber replaced a Prime subscription with a paid subscription.
    case primePaidUpgrade(PrimePaidUpgradeNotice)
    /// A gift recipient gifted a subscription to another viewer.
    case payItForward(PayItForwardNotice)
    /// A broadcaster raided the channel with the supplied audience.
    case raid(RaidNotice)
    /// A broadcaster canceled a raid.
    case unraid
    /// A broadcaster or moderator posted a chat announcement.
    case announcement(AnnouncementNotice)
    /// A viewer reached a new Bits badge tier.
    case bitsBadgeTier(BitsBadgeTierNotice)
    /// A viewer donated to the channel’s charity campaign.
    case charityDonation(CharityDonationNotice)
    /// A summary of the recipients of gifted Drops.
    case giftedDropsSummary(GiftedDropsSummaryNotice)

    /// A viewer started a subscription in the source channel during shared chat.
    case sharedChatSub(SubNotice)
    /// A subscriber shared a resubscription message in the source channel during shared
    /// chat.
    case sharedChatResub(ResubNotice)
    /// A viewer gifted a subscription to a specified recipient in the source channel
    /// during shared chat.
    case sharedChatSubGift(SubGiftNotice)
    /// A viewer gifted a batch of subscriptions to the community in the source channel
    /// during shared chat.
    case sharedChatCommunitySubGift(CommunitySubGiftNotice)
    /// A recipient replaced a gifted subscription with a paid subscription in the source
    /// channel during shared chat.
    case sharedChatGiftPaidUpgrade(GiftPaidUpgradeNotice)
    /// A subscriber replaced a Prime subscription with a paid subscription in the source
    /// channel during shared chat.
    case sharedChatPrimePaidUpgrade(PrimePaidUpgradeNotice)
    /// A gift recipient gifted a subscription to another viewer in the source channel
    /// during shared chat.
    case sharedChatPayItForward(PayItForwardNotice)
    /// A broadcaster raided the source channel during shared chat, with the supplied
    /// audience.
    case sharedChatRaid(RaidNotice)
    /// A broadcaster canceled a raid in the source channel during shared chat.
    case sharedChatUnraid
    /// A broadcaster or moderator posted a chat announcement in the source channel during
    /// shared chat.
    case sharedChatAnnouncement(AnnouncementNotice)
    /// A viewer reached a new Bits badge tier in the source channel during shared chat.
    case sharedChatBitsBadgeTier(BitsBadgeTierNotice)
    /// A viewer donated to the source channel’s charity campaign during shared chat.
    case sharedChatCharityDonation(CharityDonationNotice)
    /// A summary of gifted Drops recipients in the source channel during shared chat.
    case sharedChatGiftedDropsSummary(GiftedDropsSummaryNotice)

    /// A value Twitch did not classify or this client does not recognize.
    case unknown(String)

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let type = try container.decode(String.self, forKey: .noticeType)

      switch type {
      case "sub":
        self = .sub(try container.decode(SubNotice.self, forKey: .sub))
      case "resub":
        self = .resub(try container.decode(ResubNotice.self, forKey: .resub))
      case "sub_gift":
        self = .subGift(try container.decode(SubGiftNotice.self, forKey: .subGift))
      case "community_sub_gift":
        self = .communitySubGift(
          try container.decode(CommunitySubGiftNotice.self, forKey: .communitySubGift))
      case "gift_paid_upgrade":
        self = .giftPaidUpgrade(
          try container.decode(GiftPaidUpgradeNotice.self, forKey: .giftPaidUpgrade))
      case "prime_paid_upgrade":
        self = .primePaidUpgrade(
          try container.decode(PrimePaidUpgradeNotice.self, forKey: .primePaidUpgrade))
      case "pay_it_forward":
        self = .payItForward(
          try container.decode(PayItForwardNotice.self, forKey: .payItForward))
      case "raid":
        self = .raid(try container.decode(RaidNotice.self, forKey: .raid))
      case "unraid":
        self = .unraid
      case "announcement":
        self = .announcement(
          try container.decode(AnnouncementNotice.self, forKey: .announcement))
      case "bits_badge_tier":
        self = .bitsBadgeTier(
          try container.decode(BitsBadgeTierNotice.self, forKey: .bitsBadgeTier))
      case "charity_donation":
        self = .charityDonation(
          try container.decode(CharityDonationNotice.self, forKey: .charityDonation))
      case "gifted_drops_summary":
        self = .giftedDropsSummary(
          try container.decode(GiftedDropsSummaryNotice.self, forKey: .giftedDropsSummary)
        )
      case "shared_chat_sub":
        self = .sharedChatSub(
          try container.decode(SubNotice.self, forKey: .sharedChatSub))
      case "shared_chat_resub":
        self = .sharedChatResub(
          try container.decode(ResubNotice.self, forKey: .sharedChatResub))
      case "shared_chat_sub_gift":
        self = .sharedChatSubGift(
          try container.decode(SubGiftNotice.self, forKey: .sharedChatSubGift))
      case "shared_chat_community_sub_gift":
        self = .sharedChatCommunitySubGift(
          try container.decode(
            CommunitySubGiftNotice.self, forKey: .sharedChatCommunitySubGift))
      case "shared_chat_gift_paid_upgrade":
        self = .sharedChatGiftPaidUpgrade(
          try container.decode(
            GiftPaidUpgradeNotice.self, forKey: .sharedChatGiftPaidUpgrade))
      case "shared_chat_prime_paid_upgrade":
        self = .sharedChatPrimePaidUpgrade(
          try container.decode(
            PrimePaidUpgradeNotice.self, forKey: .sharedChatPrimePaidUpgrade))
      case "shared_chat_pay_it_forward":
        self = .sharedChatPayItForward(
          try container.decode(
            PayItForwardNotice.self, forKey: .sharedChatPayItForward))
      case "shared_chat_raid":
        self = .sharedChatRaid(
          try container.decode(RaidNotice.self, forKey: .sharedChatRaid))
      case "shared_chat_unraid":
        self = .sharedChatUnraid
      case "shared_chat_announcement":
        self = .sharedChatAnnouncement(
          try container.decode(
            AnnouncementNotice.self, forKey: .sharedChatAnnouncement))
      case "shared_chat_bits_badge_tier":
        self = .sharedChatBitsBadgeTier(
          try container.decode(BitsBadgeTierNotice.self, forKey: .sharedChatBitsBadgeTier)
        )
      case "shared_chat_charity_donation":
        self = .sharedChatCharityDonation(
          try container.decode(
            CharityDonationNotice.self, forKey: .sharedChatCharityDonation))
      case "shared_chat_gifted_drops_summary":
        self = .sharedChatGiftedDropsSummary(
          try container.decode(
            GiftedDropsSummaryNotice.self, forKey: .sharedChatGiftedDropsSummary))
      default:
        self = .unknown(type)
      }
    }
  }
}

// MARK: - Normal notice types

/// A new-subscription chat notification.
@MemberwiseInit(.public)
public struct SubNotice: Decodable, Sendable {
  /// The subscription tier.
  public let subscriptionTier: SubscriptionTier
  /// Whether the subscription uses Prime.
  public let isPrime: Bool
  /// The number of months included in the subscription.
  public let durationMonths: Int

  enum CodingKeys: String, CodingKey {
    case subscriptionTier = "subTier"
    case isPrime
    case durationMonths
  }
}

/// A resubscription chat notification with subscription history and gift details.
@MemberwiseInit(.public)
public struct ResubNotice: Decodable, Sendable {
  /// The total number of subscribed months.
  public let cumulativeMonths: Int
  /// The number of months included in the subscription.
  public let durationMonths: Int
  /// The number of consecutive subscribed months, when provided.
  public let streakMonths: Int?

  /// The subscription tier.
  public let subscriptionTier: SubscriptionTier
  /// Whether the subscription uses Prime.
  public let isPrime: Bool

  /// Gift details when available and decodable; `nil` also covers a non-gifted
  /// subscription.
  public let gift: Gift?

  enum CodingKeys: String, CodingKey {
    case cumulativeMonths
    case durationMonths
    case streakMonths
    case subscriptionTier = "subTier"
    case isPrime
    case isGift
    case gifterIsAnonymous
    case gifterID = "gifterUserId"
    case gifterDisplayName = "gifterUserName"
    case gifterLogin = "gifterUserLogin"
  }

  /// Decodes a resubscription; absent or undecodable gift details become `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    cumulativeMonths = try container.decode(Int.self, forKey: .cumulativeMonths)
    durationMonths = try container.decode(Int.self, forKey: .durationMonths)
    streakMonths = try container.decodeIfPresent(Int.self, forKey: .streakMonths)
    subscriptionTier = try container.decode(
      SubscriptionTier.self, forKey: .subscriptionTier)
    isPrime = try container.decode(Bool.self, forKey: .isPrime)
    gift = try? Gift(from: decoder)
  }

  /// The original subscription gifter, who may be anonymous.
  public enum Gift: Sendable {
    /// The user responsible for the notification chose to remain anonymous.
    case anonymous
    /// The identified user who gifted the subscription.
    case gifter(Gifter)

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let isGift = try container.decode(Bool.self, forKey: .isGift)

      if isGift {
        let gifterIsAnonymous = try container.decode(
          Bool.self, forKey: .gifterIsAnonymous)
        if gifterIsAnonymous {
          self = .anonymous
        } else {
          let gifterUserID = try container.decode(String.self, forKey: .gifterID)
          let gifterUserDisplayName = try container.decode(
            String.self, forKey: .gifterDisplayName)
          let gifterUserLogin = try container.decode(
            String.self, forKey: .gifterLogin)

          self = .gifter(
            .init(
              userID: gifterUserID, userDisplayName: gifterUserDisplayName,
              userLogin: gifterUserLogin))
        }
      } else {
        throw DecodingError.keyNotFound(
          CodingKeys.gifterID,
          .init(codingPath: decoder.codingPath, debugDescription: "Sub was not gifted"))
      }
    }

    /// The account identity of the user who gifted the resubscribed subscription.
    public struct Gifter: Sendable {
      /// The Twitch user ID.
      public let userID: String
      /// The user’s display name.
      public let userDisplayName: String
      /// The user’s login name.
      public let userLogin: String
    }
  }
}

/// A chat notification that a subscription was gifted to a user.
@MemberwiseInit(.public)
public struct SubGiftNotice: Decodable, Sendable {
  /// The number of months included in the subscription.
  public let durationMonths: Int
  /// The cumulative contribution total, when provided.
  public let cumulativeTotal: Int?

  /// The Twitch user ID of the recipient.
  public let recipientID: String
  /// The display name of the recipient.
  public let recipientDisplayName: String
  /// The login name of the recipient.
  public let recipientLogin: String

  /// The subscription tier.
  public let subscriptionTier: SubscriptionTier
  /// The identifier linking this gift to its community gift batch, when provided.
  public let communityGiftID: String?

  enum CodingKeys: String, CodingKey {
    case durationMonths
    case cumulativeTotal
    case recipientID = "recipientUserId"
    case recipientDisplayName = "recipientUserName"
    case recipientLogin = "recipientUserLogin"
    case subscriptionTier = "subTier"
    case communityGiftID = "communityGiftId"
  }
}

/// A chat notification for a batch of community gift subscriptions.
@MemberwiseInit(.public)
public struct CommunitySubGiftNotice: Decodable, Sendable {
  /// The identifier assigned by Twitch.
  public let id: String
  /// The number of subscriptions included in this community gift.
  public let total: Int
  /// The subscription tier.
  public let subscriptionTier: SubscriptionTier
  /// The cumulative contribution total, when provided.
  public let cumulativeTotal: Int?

  enum CodingKeys: String, CodingKey {
    case id
    case total
    case subscriptionTier = "subTier"
    case cumulativeTotal
  }
}

/// A chat notification that a gifted subscription became a paid subscription.
@MemberwiseInit(.public)
public struct GiftPaidUpgradeNotice: Decodable, Sendable {
  /// The gifter’s identity; `nil` means the gift was anonymous.
  public let gifter: Gifter?

  enum CodingKeys: String, CodingKey {
    case gifterIsAnonymous
    case gifterID = "gifterUserId"
    case gifterDisplayName = "gifterUserName"
    case gifterLogin = "gifterUserLogin"
  }

  /// Decodes an upgrade, mapping an anonymous gifter to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let gifterIsAnonymous = try container.decode(Bool.self, forKey: .gifterIsAnonymous)
    if gifterIsAnonymous {
      gifter = nil
    } else {
      let gifterID = try container.decode(String.self, forKey: .gifterID)
      let gifterDisplayName = try container.decode(
        String.self, forKey: .gifterDisplayName)
      let gifterLogin = try container.decode(String.self, forKey: .gifterLogin)
      gifter = .init(
        userID: gifterID, userDisplayName: gifterDisplayName, userLogin: gifterLogin)
    }
  }

  /// The account identity of the original subscription gifter.
  public struct Gifter: Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s display name.
    public let userDisplayName: String
    /// The user’s login name.
    public let userLogin: String
  }
}

/// A chat notification that a Prime subscription became a paid subscription.
@MemberwiseInit(.public)
public struct PrimePaidUpgradeNotice: Decodable, Sendable {
  /// The subscription tier.
  public let subscriptionTier: SubscriptionTier

  enum CodingKeys: String, CodingKey {
    case subscriptionTier = "subTier"
  }
}

/// A chat notification that a gift recipient gifted a subscription onward.
@MemberwiseInit(.public)
public struct PayItForwardNotice: Decodable, Sendable {
  /// The gifter’s identity; `nil` means the gift was anonymous.
  public let gifter: Gifter?

  enum CodingKeys: String, CodingKey {
    case gifterIsAnonymous
    case gifterID = "gifterUserId"
    case gifterDisplayName = "gifterUserName"
    case gifterLogin = "gifterUserLogin"
  }

  /// Decodes a gift, mapping an anonymous original gifter to `nil`.
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let gifterIsAnonymous = try container.decode(Bool.self, forKey: .gifterIsAnonymous)
    if gifterIsAnonymous {
      gifter = nil
    } else {
      let gifterID = try container.decode(String.self, forKey: .gifterID)
      let gifterDisplayName = try container.decode(
        String.self, forKey: .gifterDisplayName)
      let gifterLogin = try container.decode(String.self, forKey: .gifterLogin)
      gifter = .init(
        userID: gifterID, userDisplayName: gifterDisplayName, userLogin: gifterLogin)
    }
  }

  /// The account identity of the user whose gift prompted this subscription gift.
  public struct Gifter: Sendable {
    /// The Twitch user ID.
    public let userID: String
    /// The user’s display name.
    public let userDisplayName: String
    /// The user’s login name.
    public let userLogin: String
  }
}

/// A chat notification for an incoming raid and its audience.
@MemberwiseInit(.public)
public struct RaidNotice: Decodable, Sendable {
  /// The Twitch user ID.
  public let userID: String
  /// The user’s display name.
  public let userDisplayName: String
  /// The user’s login name.
  public let userLogin: String
  /// The number of viewers reported by Twitch.
  public let viewerCount: Int
  /// The URL for profile image.
  public let profileImageURL: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case viewerCount
    case profileImageURL = "profileImageUrl"
  }
}

/// A channel announcement’s chat notification metadata.
@MemberwiseInit(.public)
public struct AnnouncementNotice: Decodable, Sendable {
  /// The color reported by Twitch.
  public let color: String
}

/// A chat notification that a user reached a Bits badge tier.
@MemberwiseInit(.public)
public struct BitsBadgeTierNotice: Decodable, Sendable {
  /// The subscription or Bits badge tier reported by the notification.
  public let tier: Int
}

/// A chat notification describing a charity donation.
@MemberwiseInit(.public)
public struct CharityDonationNotice: Decodable, Sendable {
  /// The name of the charity.
  public let charityName: String
  /// The amount contributed or donated.
  public let amount: CharityDonationEvent.CharityAmount
}

/// A chat notification summarizing gifted Drops.
@MemberwiseInit(.public)
public struct GiftedDropsSummaryNotice: Decodable, Sendable {
  /// The number of recipients.
  public let recipientCount: Int
}
