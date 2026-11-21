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
    if let credentials, credentials.user == nil {
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
              guard let intent = await client?.takeIRCReaderIntent(for: id) else { return }
              try await pool.setChannels(
                intent.roomIDs.keys.sorted(), retrying: intent.retries,
                expectedRoomIDs: intent.roomIDs)
            }
          }

          defer { group.cancelAll() }
          for try await update in updates {
            await client?.withChat { $0.receiveIRC(update, role: .read, from: id) }
          }
        }
      } catch {
        if !Task.isCancelled {
          await client?.withChat { $0.ircTransportFailed(error, role: .read, from: id) }
        }
      }
    }
  }

  fileprivate func takeIRCReaderIntent(for id: UUID) -> (
    roomIDs: [String: String], retries: Set<String>
  )? {
    guard reader?.id == id else { return nil }

    let roomIDs = Dictionary(
      uniqueKeysWithValues: memberships.values.map {
        ($0.channel.login, $0.channel.id)
      })
    let retries = readerRetryLogins.intersection(roomIDs.keys)
    readerRetryLogins.subtract(retries)
    return (roomIDs, retries)
  }

  @discardableResult
  func retireChatReader() -> Task<Void, Never>? {
    let retiring = reader
    reader = nil
    ircReaderState = nil
    readerStatus = .idle
    readerRetryLogins.removeAll()

    guard let retiring else { return nil }

    retiring.changes.finish()
    retiring.task.cancel()
    return Task { await retiring.pool.disconnect() }
  }

  func updateIRCReaderState(_ state: IRCState) {
    ircReaderState = state
    readerStatus = state.status.chatStatus
    for member in memberships.values {
      let login = member.channel.login
      guard state.expectedRoomIDs[login] == member.channel.id,
        let status = state.channels[login]
      else { continue }
      switch status {
      case .joining: member.updateStatus(.connecting)
      case .joined: member.updateStatus(.ready)
      case .reconnecting: member.updateStatus(.reconnecting)
      case .failed(let reason): member.updateStatus(.failed(String(describing: reason)))
      }
    }
  }
}

extension TwitchClient {
  fileprivate func takeIRCReaderIntent(for id: UUID) -> (
    roomIDs: [String: String], retries: Set<String>
  )? {
    chat.takeIRCReaderIntent(for: id)
  }
}
