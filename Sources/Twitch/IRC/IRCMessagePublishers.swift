#if canImport(Combine)
  @preconcurrency import Combine
  import Foundation

  /// Synchronous per-subscriber registration without hopping to the client actor.
  /// Delivery runs off the client actor in FIFO order; downstream calls never hold the
  /// registry lock.
  internal final class IRCMessagePublishers: @unchecked Sendable {
    private enum Delivery: Sendable {
      case message(IRCMessage)
      case finish
    }

    private final class Registry: @unchecked Sendable {
      private let lock = NSLock()
      private var subjects: [UUID: PassthroughSubject<IRCMessage, Never>] = [:]
      private var finished = false

      func attach(_ subject: PassthroughSubject<IRCMessage, Never>, id: UUID) -> Bool {
        lock.withLock {
          if finished { return true }
          subjects[id] = subject
          return false
        }
      }

      func remove(_ id: UUID) {
        _ = lock.withLock { subjects.removeValue(forKey: id) }
      }

      func markFinished() -> Bool {
        lock.withLock {
          guard !finished else { return false }
          finished = true
          return true
        }
      }

      func send(_ message: IRCMessage) {
        let subjects = lock.withLock { Array(subjects.values) }
        for subject in subjects { subject.send(message) }
      }

      func finishAll() {
        let subjects = lock.withLock {
          finished = true
          let subjects = Array(subjects.values)
          self.subjects.removeAll()
          return subjects
        }
        for subject in subjects { subject.send(completion: .finished) }
      }
    }

    private let registry = Registry()
    private let delivery: AsyncStream<Delivery>.Continuation

    init() {
      let (stream, continuation) = AsyncStream<Delivery>.makeStream(bufferingPolicy: .unbounded)
      self.delivery = continuation
      let registry = self.registry
      Task.detached {
        for await item in stream {
          switch item {
          case .message(let message):
            registry.send(message)
          case .finish:
            registry.finishAll()
            return
          }
        }
        registry.finishAll()
      }
    }

    deinit {
      finish()
    }

    func publisher() -> AnyPublisher<IRCMessage, Never> {
      let registry = self.registry
      return Deferred {
        let id = UUID()
        let subject = PassthroughSubject<IRCMessage, Never>()

        // Subjects retain completion for subscribers attaching after shutdown.
        if registry.attach(subject, id: id) {
          subject.send(completion: .finished)
        }

        return subject.handleEvents(
          receiveCancel: { registry.remove(id) }
        )
      }.eraseToAnyPublisher()
    }

    func yield(_ message: IRCMessage) {
      delivery.yield(.message(message))
    }

    func finish() {
      if registry.markFinished() {
        delivery.yield(.finish)
      }
      delivery.finish()
    }
  }
#endif
