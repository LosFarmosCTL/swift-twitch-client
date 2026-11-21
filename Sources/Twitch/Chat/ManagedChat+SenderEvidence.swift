import Foundation

extension ManagedChat {
  /// Newer direct observations outrank bootstrap discovery and survive part/rejoin.
  struct SenderEvidence {
    var observedPrivilege: ChatPrivilege?
    var privilegeOverride: ChatPrivilege?
    var restriction = ChatSendRestriction.none
  }

  func setChatPrivilege(_ privilege: ChatPrivilege?, in channelID: String) {
    guard credentials != nil else { return }

    senderEvidence[.id(channelID), default: SenderEvidence()].privilegeOverride = privilege
    memberships[channelID]?.moderationBlocked = false
    reconcileChatModeration(channelID)
    publishChatState()
  }

  internal func effectiveChatPrivilege(_ id: String) -> ChatPrivilege {
    let evidence = senderEvidence[.id(id)]
    var privilege = evidence?.privilegeOverride ?? evidence?.observedPrivilege ?? .unknown

    if id == credentials?.userID {
      privilege.isBroadcaster = true
      privilege.isKnown = true
    }

    return privilege
  }

  func observeSenderBadges(
    userID: String?, isSourceChannel: Bool, hasBadges: Bool = true,
    in id: String, badgeIDs: @autoclosure () -> [String]
  ) -> Bool {
    guard let userID, userID == credentials?.userID, isSourceChannel, hasBadges else {
      return false
    }
    observeChatPrivilege(ChatPrivilege(badgeIDs: badgeIDs()), in: id)
    return true
  }

  func observeChatPrivilege(_ privilege: ChatPrivilege, in id: String) {
    if senderEvidence[.id(id)]?.observedPrivilege != privilege {
      memberships[id]?.moderationBlocked = false
    }

    senderEvidence[.id(id), default: SenderEvidence()].observedPrivilege = privilege
    reconcileChatModeration(id)
  }

  internal func startModerationPrefillIfNeeded() {
    let revision = credentialRevision
    guard configuration.prefillModeratedChannels, let credentials,
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
    guard credentialRevision == revision, !isShutdown else {
      return
    }

    for channel in channels {
      cacheChatChannel(ChatChannel(id: channel.id, login: channel.login))
      // Discovery may complete after a newer USERSTATE or moderation event. It is
      // weaker evidence and must not revive a role that was authoritatively lost.
      if senderEvidence[.id(channel.id)]?.observedPrivilege?.isKnown != true {
        senderEvidence[.id(channel.id), default: SenderEvidence()].observedPrivilege =
          ChatPrivilege(
            isModerator: true)
        reconcileChatModeration(channel.id)
      }
    }

    publishChatState()
  }
}
