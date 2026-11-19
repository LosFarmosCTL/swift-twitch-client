import Foundation

extension EventSubClient {
  private static let eventSubURL = URL(string: "wss://eventsub.wss.twitch.tv/ws")!
  private static let maxSessions = 3

  // MARK: - Opening sessions

  func openSessionIfNeeded() {
    guard sessions.opening == nil else { return }

    // A closing session still counts until its sockets have shut down.
    let occupied = sessions.active.count + sessions.closing.count
    guard occupied < Self.maxSessions else { return }

    let sessionID = UUID()
    let connection = makeSessionConnection(in: sessionID, at: Self.eventSubURL)
    let task = Task<Void, Never> { [weak self] in
      await self?.openSession(sessionID, connection: connection)
    }

    sessions.opening = (sessionID, SocketHandshake(connection: connection, task: task))
  }

  private func openSession(_ sessionID: UUID, connection: EventSubConnection) async {
    do {
      let twitchSessionID = try await connection.connect()
      guard sessions.opening?.id == sessionID else { return }

      // Install the session before its reader can deliver frames.
      sessions.opening = nil
      sessions.active[sessionID] = Session(twitchSessionID: twitchSessionID, connection: connection)

      try await connection.startReceiving()
      serveSlotWaiters()

      // All waiters may have cancelled while the reader was starting.
      if sessions.active[sessionID]?.slots.isEmpty == true { closeSession(sessionID) }
    } catch {
      failOpeningSession(sessionID, error: error)
    }
  }

  private func failOpeningSession(_ sessionID: UUID, error: any Error) {
    let setupError = EventSubError.normalizeSetupError(error)

    if let opening = sessions.opening, opening.id == sessionID {
      sessions.opening = nil
      _ = startClosingSession(sessionID, connections: [opening.handshake.connection])
    } else if sessions.active[sessionID] != nil {
      failSession(sessionID, error: setupError as? EventSubError ?? .disconnected(with: setupError))
    } else {
      // A reset or cancellation already took ownership of shutdown.
      return
    }

    failSlotWaiters(throwing: setupError)
  }

  func makeSessionConnection(in sessionID: UUID, at url: URL) -> EventSubConnection {
    let socketID = UUID()
    return EventSubConnection(
      id: socketID, network: network, decoder: decoder, eventSubURL: url
    ) { [weak self] update in
      await self?.receiveSocket(update, in: sessionID, from: socketID)
    }
  }

  // MARK: - Closing sessions

  func beginClosingSessions() -> [Task<Void, Never>] {
    _ = cancelOpeningSession()
    for sessionID in Array(sessions.active.keys) { closeSession(sessionID) }
    failSlotWaiters(throwing: CancellationError())

    return Array(sessions.closing.values)
  }

  func failSession(_ sessionID: UUID, error: EventSubError) {
    closeSession(sessionID)
    failSubscriptions(in: sessionID, error: error)
  }

  func cancelOpeningSession() -> Task<Void, Never>? {
    guard let opening = sessions.opening else { return nil }

    sessions.opening = nil
    return startClosingSession(opening.id, connections: [], handshake: opening.handshake)
  }

  func closeSession(_ sessionID: UUID) {
    guard let session = sessions.active.removeValue(forKey: sessionID) else { return }

    let connections = [session.connection] + Array(session.drainingConnections.values)
    _ = startClosingSession(sessionID, connections: connections, handshake: session.replacement)
  }

  private func startClosingSession(
    _ sessionID: UUID, connections: [EventSubConnection], handshake: SocketHandshake? = nil
  ) -> Task<Void, Never> {
    handshake?.task.cancel()

    let sockets = if let handshake { connections + [handshake.connection] } else { connections }
    let closing = Task { [weak self] in
      await withTaskGroup(of: Void.self) { group in
        for socket in sockets {
          group.addTask { await socket.cancel() }
        }
      }

      // The handshake may still be returning from the network.
      await handshake?.task.value
      await self?.finishClosingSession(sessionID)
    }

    sessions.closing[sessionID] = closing
    return closing
  }

  private func finishClosingSession(_ sessionID: UUID) {
    sessions.closing[sessionID] = nil
    serveSlotWaiters()
  }

  struct SocketHandshake: Sendable {
    let connection: EventSubConnection
    let task: Task<Void, Never>
  }
}
