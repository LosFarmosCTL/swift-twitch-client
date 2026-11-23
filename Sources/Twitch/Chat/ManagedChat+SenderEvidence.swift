import Foundation

/// Tracks per-channel sender privileges and ban/timeout restrictions for the active user.
///
/// Resolved evidence is keyed by Twitch channel ID. Unjoined raw IRC writes may receive
/// `USERSTATE` or `NOTICE` frames before the channel's ID is known; those are held in
/// `pendingByLogin` and promoted as soon as the channel is cached.
internal struct ChatSenderEvidenceStore {
  struct ChannelEvidence {
    var observedPrivilege: ChatPrivilege?
    var privilegeOverride: ChatPrivilege?
    var restriction = ChatSendRestriction.none
  }

  struct PendingLoginEvidence {
    var observedPrivilege: ChatPrivilege?
    var isBanned = false
  }

  private var byChannelID: [String: ChannelEvidence] = [:]
  private var pendingByLogin: [String: PendingLoginEvidence] = [:]

  mutating func removeAll() {
    byChannelID.removeAll()
    pendingByLogin.removeAll()
  }

  func effectivePrivilege(for channelID: String, currentUserID: String?) -> ChatPrivilege {
    let evidence = byChannelID[channelID]
    var privilege = evidence?.privilegeOverride ?? evidence?.observedPrivilege ?? .unknown

    if channelID == currentUserID {
      privilege.isBroadcaster = true
      privilege.isKnown = true
    }

    return privilege
  }

  func observedPrivilege(for channelID: String) -> ChatPrivilege? {
    byChannelID[channelID]?.observedPrivilege
  }

  mutating func setPrivilegeOverride(_ privilege: ChatPrivilege?, for channelID: String) {
    byChannelID[channelID, default: ChannelEvidence()].privilegeOverride = privilege
  }

  /// Records directly observed privilege evidence. Returns `true` if the stored value changed.
  @discardableResult
  mutating func observePrivilege(_ privilege: ChatPrivilege, for channelID: String) -> Bool {
    guard byChannelID[channelID]?.observedPrivilege != privilege else { return false }
    byChannelID[channelID, default: ChannelEvidence()].observedPrivilege = privilege
    return true
  }

  /// Records weaker moderator-discovery evidence without overwriting a newer direct observation.
  @discardableResult
  mutating func observeDiscoveredModerator(for channelID: String) -> Bool {
    guard byChannelID[channelID]?.observedPrivilege?.isKnown != true else { return false }
    byChannelID[channelID, default: ChannelEvidence()].observedPrivilege = ChatPrivilege(
      isModerator: true)
    return true
  }

  mutating func recordPendingLoginPrivilege(_ privilege: ChatPrivilege, login: String) {
    let normalized = IRCWireMessage.channelLogin(login)
    pendingByLogin[normalized, default: PendingLoginEvidence()].observedPrivilege = privilege
  }

  mutating func recordPendingLoginBan(login: String) {
    let normalized = IRCWireMessage.channelLogin(login)
    pendingByLogin[normalized, default: PendingLoginEvidence()].isBanned = true
  }

  mutating func takePendingEvidence(forLogin login: String) -> PendingLoginEvidence? {
    pendingByLogin.removeValue(forKey: IRCWireMessage.channelLogin(login))
  }

  func restrictionBlock(for channelID: String, at now: ContinuousClock.Instant) -> ChatSendBlock? {
    byChannelID[channelID]?.restriction.block(at: now)
  }

  @discardableResult
  mutating func recordBan(for channelID: String) -> Bool {
    if case .banned = byChannelID[channelID]?.restriction { return false }
    byChannelID[channelID, default: ChannelEvidence()].restriction = .banned
    return true
  }

  @discardableResult
  mutating func recordTimeout(until: Date?, for channelID: String) -> Bool {
    if until == nil,
      case .timedOut(_, let deadline?) = byChannelID[channelID]?.restriction,
      deadline > .now
    {
      // An IRC report without a timestamp must not erase a known expiry.
      return false
    }
    byChannelID[channelID, default: ChannelEvidence()].restriction = .timeout(until: until)
    return true
  }

  @discardableResult
  mutating func clearRestriction(for channelID: String) -> Bool {
    guard let existing = byChannelID[channelID] else { return false }
    if case .none = existing.restriction { return false }
    byChannelID[channelID]?.restriction = .none
    return true
  }
}

extension ManagedChat {
  func setChatPrivilege(_ privilege: ChatPrivilege?, in channelID: String) {
    guard !isShutdown, credentials?.user != nil else { return }

    senderEvidence.setPrivilegeOverride(privilege, for: channelID)
    memberships[channelID]?.moderationBlocked = false
    reconcileChatModeration(channelID)
    publishChatState()
  }

  internal func effectiveChatPrivilege(_ id: String) -> ChatPrivilege {
    senderEvidence.effectivePrivilege(for: id, currentUserID: credentials?.userID)
  }

  func observeSenderBadges(
    userID: String?, isSourceChannel: Bool, hasBadges: Bool = true,
    in id: String, badgeIDs: @autoclosure () -> [String]
  ) -> Bool {
    guard let userID, userID == credentials?.userID, isSourceChannel, hasBadges else {
      return false
    }
    return observeChatPrivilege(ChatPrivilege(badgeIDs: badgeIDs()), in: id)
  }

  @discardableResult
  func observeChatPrivilege(_ privilege: ChatPrivilege, in id: String) -> Bool {
    let changed = senderEvidence.observePrivilege(privilege, for: id)
    if changed {
      memberships[id]?.moderationBlocked = false
    }
    reconcileChatModeration(id)
    return changed
  }

  func promotePendingSenderEvidence(for channel: ChatChannel) {
    guard let pending = senderEvidence.takePendingEvidence(forLogin: channel.login) else {
      return
    }
    if let privilege = pending.observedPrivilege {
      observeChatPrivilege(privilege, in: channel.id)
    }
    if pending.isBanned {
      senderEvidence.recordBan(for: channel.id)
      sendDestinations.insert(channel.id)
    }
  }

  internal func startModerationPrefillIfNeeded() {
    let revision = credentialRevision
    guard !isShutdown, configuration.prefillModeratedChannels, let credentials,
      credentials.scopes?.contains("user:read:moderated_channels") == true,
      credentials.user != nil, prefill == nil
    else { return }

    let network = self.network

    prefill = Task { [weak client, diagnostics] in
      var cursor: String?
      repeat {
        do {
          try Task.checkCancellation()
          let response = try await TwitchClient.helix(
            for: .getModeratedChannels(limit: 100, after: cursor),
            credentials: credentials, network: network, diagnostics: diagnostics)
          await client?.withChat {
            $0.acceptChatModeratedChannels(
              response.value.channels, revision: revision)
          }
          cursor = response.value.cursor
        } catch { return }
      } while cursor != nil
    }
  }

  private func acceptChatModeratedChannels(
    _ channels: [ModeratedChannel], revision: UInt64
  ) {
    guard credentialRevision == revision, !isShutdown else { return }

    for channel in channels {
      cacheChatChannel(ChatChannel(id: channel.id, login: channel.login))
      // Discovery may complete after a newer USERSTATE or moderation event. It is
      // weaker evidence and must not revive a role that was authoritatively lost.
      if senderEvidence.observeDiscoveredModerator(for: channel.id) {
        reconcileChatModeration(channel.id)
      }
    }

    publishChatState()
  }
}
