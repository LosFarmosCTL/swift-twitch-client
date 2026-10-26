import MemberwiseInit

@MemberwiseInit(.public)
public struct ChannelChatNotificationEvent: Event {
  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterDisplayName: String

  public let chatter: Chatter

  public let color: String
  public let badges: [ChannelChatMessageEvent.Badge]

  public let messageID: String
  public let message: ChannelChatMessageEvent.Message
  public let systemMessage: String

  public let noticeType: NoticeType

  public let sourceBroadcasterID: String?
  public let sourceBroadcasterLogin: String?
  public let sourceBroadcasterDisplayName: String?
  public let sourceMessageID: String?
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

  public enum Chatter: Sendable {
    case anonymous
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

    public struct ChatterInfo: Sendable {
      public let userID: String
      public let userDisplayName: String
      public let userLogin: String
    }
  }

  public enum NoticeType: Sendable {
    case sub(SubNotice)
    case resub(ResubNotice)
    case subGift(SubGiftNotice)
    case communitySubGift(CommunitySubGiftNotice)
    case giftPaidUpgrade(GiftPaidUpgradeNotice)
    case primePaidUpgrade(PrimePaidUpgradeNotice)
    case payItForward(PayItForwardNotice)
    case raid(RaidNotice)
    case unraid
    case announcement(AnnouncementNotice)
    case bitsBadgeTier(BitsBadgeTierNotice)
    case charityDonation(CharityDonationNotice)
    case giftedDropsSummary(GiftedDropsSummaryNotice)

    case sharedChatSub(SubNotice)
    case sharedChatResub(ResubNotice)
    case sharedChatSubGift(SubGiftNotice)
    case sharedChatCommunitySubGift(CommunitySubGiftNotice)
    case sharedChatGiftPaidUpgrade(GiftPaidUpgradeNotice)
    case sharedChatPrimePaidUpgrade(PrimePaidUpgradeNotice)
    case sharedChatPayItForward(PayItForwardNotice)
    case sharedChatRaid(RaidNotice)
    case sharedChatUnraid
    case sharedChatAnnouncement(AnnouncementNotice)
    case sharedChatBitsBadgeTier(BitsBadgeTierNotice)
    case sharedChatCharityDonation(CharityDonationNotice)
    case sharedChatGiftedDropsSummary(GiftedDropsSummaryNotice)

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

@MemberwiseInit(.public)
public struct SubNotice: Decodable, Sendable {
  public let subscriptionTier: SubscriptionTier
  public let isPrime: Bool
  public let durationMonths: Int

  enum CodingKeys: String, CodingKey {
    case subscriptionTier = "subTier"
    case isPrime
    case durationMonths
  }
}

@MemberwiseInit(.public)
public struct ResubNotice: Decodable, Sendable {
  public let cumulativeMonths: Int
  public let durationMonths: Int
  public let streakMonths: Int?

  public let subscriptionTier: SubscriptionTier
  public let isPrime: Bool

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

  public enum Gift: Sendable {
    case anonymous
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

    public struct Gifter: Sendable {
      public let userID: String
      public let userDisplayName: String
      public let userLogin: String
    }
  }
}

@MemberwiseInit(.public)
public struct SubGiftNotice: Decodable, Sendable {
  public let durationMonths: Int
  public let cumulativeTotal: Int?

  public let recipientID: String
  public let recipientDisplayName: String
  public let recipientLogin: String

  public let subscriptionTier: SubscriptionTier
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

@MemberwiseInit(.public)
public struct CommunitySubGiftNotice: Decodable, Sendable {
  public let id: String
  public let total: Int
  public let subscriptionTier: SubscriptionTier
  public let cumulativeTotal: Int?

  enum CodingKeys: String, CodingKey {
    case id
    case total
    case subscriptionTier = "subTier"
    case cumulativeTotal
  }
}

@MemberwiseInit(.public)
public struct GiftPaidUpgradeNotice: Decodable, Sendable {
  public let gifter: Gifter?

  enum CodingKeys: String, CodingKey {
    case gifterIsAnonymous
    case gifterID = "gifterUserId"
    case gifterDisplayName = "gifterUserName"
    case gifterLogin = "gifterUserLogin"
  }

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

  public struct Gifter: Sendable {
    public let userID: String
    public let userDisplayName: String
    public let userLogin: String
  }
}

@MemberwiseInit(.public)
public struct PrimePaidUpgradeNotice: Decodable, Sendable {
  public let subscriptionTier: SubscriptionTier

  enum CodingKeys: String, CodingKey {
    case subscriptionTier = "subTier"
  }
}

@MemberwiseInit(.public)
public struct PayItForwardNotice: Decodable, Sendable {
  public let gifter: Gifter?

  enum CodingKeys: String, CodingKey {
    case gifterIsAnonymous
    case gifterID = "gifterUserId"
    case gifterDisplayName = "gifterUserName"
    case gifterLogin = "gifterUserLogin"
  }

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

  public struct Gifter: Sendable {
    public let userID: String
    public let userDisplayName: String
    public let userLogin: String
  }
}

@MemberwiseInit(.public)
public struct RaidNotice: Decodable, Sendable {
  public let userID: String
  public let userDisplayName: String
  public let userLogin: String
  public let viewerCount: Int
  public let profileImageURL: String

  enum CodingKeys: String, CodingKey {
    case userID = "userId"
    case userDisplayName = "userName"
    case userLogin
    case viewerCount
    case profileImageURL = "profileImageUrl"
  }
}

@MemberwiseInit(.public)
public struct AnnouncementNotice: Decodable, Sendable {
  public let color: String
}

@MemberwiseInit(.public)
public struct BitsBadgeTierNotice: Decodable, Sendable {
  public let tier: Int
}

@MemberwiseInit(.public)
public struct CharityDonationNotice: Decodable, Sendable {
  public let charityName: String
  public let amount: CharityDonationEvent.CharityAmount
}

@MemberwiseInit(.public)
public struct GiftedDropsSummaryNotice: Decodable, Sendable {
  public let recipientCount: Int
}
