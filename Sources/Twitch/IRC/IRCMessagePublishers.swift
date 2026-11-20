#if canImport(Combine)
  @preconcurrency import Combine
  import Foundation

  /// Synchronous per-subscriber registration without hopping to the client actor.
  /// Registry state is locked; the actor serializes yield/finish. Never call
  /// downstream while holding the registry lock.
  internal final class IRCMessagePublishers: @unchecked Sendable {
    private let lock = NSLock()
    private var subjects: [UUID: PassthroughSubject<IRCMessage, Never>] = [:]
    private var finished = false

    func publisher() -> AnyPublisher<IRCMessage, Never> {
      Deferred { [self] in
        let id = UUID()
        let subject = PassthroughSubject<IRCMessage, Never>()
        let finished = lock.withLock {
          if self.finished { return true }
          subjects[id] = subject
          return false
        }

        // Subjects retain completion for subscribers attaching after shutdown.
        if finished { subject.send(completion: .finished) }

        return subject.handleEvents(
          receiveCancel: { [weak self] in self?.remove(id) }
        )
      }.eraseToAnyPublisher()
    }

    func yield(_ message: IRCMessage) {
      let subjects = lock.withLock { Array(subjects.values) }
      for subject in subjects { subject.send(message) }
    }

    func finish() {
      let subjects = lock.withLock {
        guard !finished else { return [PassthroughSubject<IRCMessage, Never>]() }
        finished = true
        let subjects = Array(subjects.values)
        self.subjects.removeAll()
        return subjects
      }

      for subject in subjects { subject.send(completion: .finished) }
    }

    private func remove(_ id: UUID) {
      _ = lock.withLock { subjects.removeValue(forKey: id) }
    }
  }
#endif
