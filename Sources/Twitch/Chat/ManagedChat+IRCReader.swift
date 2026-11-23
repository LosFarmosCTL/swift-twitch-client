import Foundation

extension ManagedChat {
  struct IRCReader {
    let id: UUID
    let pool: IRCConnectionPool
    let changes: AsyncStream<Void>.Continuation
    let task: Task<Void, Never>
  }

  func startIRCReaderIfNeeded(authentication: ChatConfiguration.IRCAuthentication) {
    if case .failed = readerStatus {
      retireChatReader()
      for member in memberships.values { member.updateStatus(.reconnecting) }
    }
    guard reader == nil else { return }

    let credentials = authentication == .authenticated ? self.credentials : nil
    if authentication == .authenticated, credentials?.user == nil {
      let status = ChatComponentStatus.unavailable(
        "A user access token is required for authenticated IRC.")
      readerStatus = status
      for member in memberships.values { member.updateStatus(status) }
      return
    }

    let pool = IRCConnectionPool(with: credentials, network: network)
    let id = UUID()
    let (changes, notifyChanges) = AsyncStream<Void>.makeStream(
      bufferingPolicy: .bufferingNewest(1))
    let task = startIRCReaderTask(pool, id: id, changes: changes)

    reader = IRCReader(id: id, pool: pool, changes: notifyChanges, task: task)
    readerStatus = .connecting
  }

  func updateIRCReaderMembership() {
    if memberships.isEmpty {
      retireChatReader()
    } else {
      reader?.changes.yield(())
    }
  }

  private func startIRCReaderTask(
    _ pool: IRCConnectionPool, id: UUID, changes: AsyncStream<Void>
  ) -> Task<Void, Never> {
    Task { [weak client] in
      do {
        let updates = try await pool.start()
        try await withThrowingTaskGroup(of: Void.self) { group in
          group.addTask { [weak client] in
            for await _ in changes {
              guard let targets = await client?.takeIRCReaderTargets(for: id) else { return }
              try await pool.setTargets(targets)
            }
          }

          defer { group.cancelAll() }
          for try await update in updates {
            await client?.withChat { $0.receiveIRCReader(update, from: id) }
          }
        }
      } catch {
        if !Task.isCancelled {
          await client?.withChat { $0.ircTransportFailed(error, role: .read, from: id) }
        }
      }
    }
  }

  fileprivate func takeIRCReaderTargets(for id: UUID) -> [IRCConnectionPool.ChannelTarget]? {
    guard reader?.id == id else { return nil }
    return memberships.values.map {
      IRCConnectionPool.ChannelTarget(
        login: $0.channel.login,
        expectedRoomID: $0.channel.id,
        token: $0.generation)
    }
  }

  @discardableResult
  func retireChatReader() -> Task<Void, Never>? {
    let retiring = reader
    reader = nil
    ircReaderState = nil
    readerStatus = .idle

    guard let retiring else { return nil }

    retiring.changes.finish()
    retiring.task.cancel()
    return Task { await retiring.pool.disconnect() }
  }

  func receiveIRCReader(_ update: IRCConnectionPool.Update, from id: UUID) {
    guard id == reader?.id else { return }

    switch update {
    case .message(let message):
      emitChatIRCMessage(message, role: .read)
    case .state(let poolState):
      updateIRCReaderState(poolState)
      publishChatState()
    }
  }

  private func updateIRCReaderState(_ poolState: IRCConnectionPool.PoolState) {
    ircReaderState = poolState.ircState
    readerStatus = poolState.ircState.status.chatStatus

    for member in memberships.values {
      guard let channelState = poolState.channels[member.channel.login],
        channelState.token == member.generation,
        channelState.expectedRoomID == member.channel.id
      else { continue }

      member.updateStatus(channelState.status.chatStatus)
    }
  }
}

extension TwitchClient {
  fileprivate func takeIRCReaderTargets(for id: UUID) -> [IRCConnectionPool.ChannelTarget]? {
    chat.takeIRCReaderTargets(for: id)
  }
}
