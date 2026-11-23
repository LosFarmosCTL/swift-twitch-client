import Foundation

internal enum ChatChannelReference: Hashable, Sendable {
  case id(String)
  case login(String)

  init(login: String) { self = .login(IRCWireMessage.channelLogin(login)) }

  init(_ target: ChatChannelTarget) {
    switch target {
    case .id(let id): self = .id(id)
    case .login(let login): self.init(login: login)
    }
  }

  fileprivate func endpoint() throws -> HelixEndpoint<[User]> {
    switch self {
    case .id(let id):
      guard !id.isEmpty else { throw ChatError.invalidChannel }
      return .getUsers(userIDs: [id])
    case .login(let login):
      guard IRCWireMessage.isLogin(login) else { throw ChatError.invalidChannel }
      return .getUsers(userLogins: [login])
    }
  }
}

/// Maintains a 1-to-1 cache between Twitch channel IDs and normalized logins,
/// evicting stale aliases whenever a channel is renamed or reassigned.
internal struct ChatChannelDirectory: Sendable {
  private var byID: [String: ChatChannel] = [:]
  private var byLogin: [String: ChatChannel] = [:]

  subscript(_ reference: ChatChannelReference) -> ChatChannel? {
    switch reference {
    case .id(let id): byID[id]
    case .login(let login): byLogin[IRCWireMessage.channelLogin(login)]
    }
  }

  func channel(id: String) -> ChatChannel? { byID[id] }
  func channel(login: String) -> ChatChannel? { byLogin[IRCWireMessage.channelLogin(login)] }

  mutating func insert(_ channel: ChatChannel) {
    if let previous = byID[channel.id], previous.login != channel.login {
      byLogin[previous.login] = nil
    }
    if let previous = byLogin[channel.login], previous.id != channel.id {
      byID[previous.id] = nil
    }
    byID[channel.id] = channel
    byLogin[channel.login] = channel
  }
}

extension ManagedChat {
  final class ChannelLookup {
    let id: UUID
    let task: Task<Void, Never>
    var waiters: [UUID: CheckedContinuation<ChatChannel, any Error>] = [:]

    init(id: UUID, task: Task<Void, Never>) {
      self.id = id
      self.task = task
    }
  }

  func cacheChatChannel(_ channel: ChatChannel) {
    knownChannels.insert(channel)
    promotePendingSenderEvidence(for: channel)
  }

  nonisolated(nonsending) func resolveChatChannel(
    _ reference: ChatChannelReference, waiterID: UUID = UUID()
  ) async throws -> ChatChannel {
    try Task.checkCancellation()
    guard !isShutdown else { throw ChatError.shutdown }
    if let channel = activeMembership(for: reference)?.channel ?? knownChannels[reference] {
      return channel
    }

    let endpoint = try reference.endpoint()
    let revision = credentialRevision
    let lookup = lookups[reference] ?? startLookup(reference, endpoint: endpoint)

    let channel = try await withTaskCancellationHandler {
      try await waitForLookup(lookup, waiterID: waiterID)
    } onCancel: { [weak client] in
      Task {
        await client?.withChat {
          $0.cancelLookupWaiter(waiterID, for: reference, error: CancellationError())
        }
      }
    }

    try checkCredentialRevision(revision)
    return channel
  }

  nonisolated(nonsending) private func waitForLookup(
    _ lookup: ChannelLookup, waiterID: UUID
  ) async throws -> ChatChannel {
    try Task.checkCancellation()
    return try await withCheckedThrowingContinuation { reply in
      lookup.waiters[waiterID] = reply
    }
  }

  private func startLookup(
    _ reference: ChatChannelReference,
    endpoint: HelixEndpoint<[User]>
  ) -> ChannelLookup {
    let id = UUID()
    let task = Task { [weak client, credentials, network, diagnostics] in
      let result: Result<ChatChannel, any Error>
      do {
        let response = try await TwitchClient.helix(
          for: endpoint, credentials: credentials, network: network, diagnostics: diagnostics)
        guard let user = response.value.first else { throw ChatError.channelNotFound }
        result = .success(ChatChannel(id: user.id, login: user.login))
      } catch {
        result = .failure(error)
      }
      await client?.withChat { $0.finishLookup(reference, id: id, result: result) }
    }
    let lookup = ChannelLookup(id: id, task: task)
    lookups[reference] = lookup
    return lookup
  }

  func cancelLookupWaiter(_ id: UUID, for reference: ChatChannelReference, error: any Error) {
    lookups[reference]?.waiters.removeValue(forKey: id)?.resume(throwing: error)
  }

  func cancelLookups(throwing error: ChatError) {
    let previous = lookups
    lookups.removeAll()

    for lookup in previous.values {
      lookup.task.cancel()
      for reply in lookup.waiters.values { reply.resume(throwing: error) }
    }
  }

  private func finishLookup(
    _ reference: ChatChannelReference, id: UUID, result: Result<ChatChannel, any Error>
  ) {
    guard lookups[reference]?.id == id, let lookup = lookups.removeValue(forKey: reference)
    else { return }

    if case .success(let channel) = result { cacheChatChannel(channel) }
    for reply in lookup.waiters.values { reply.resume(with: result) }
  }
}
