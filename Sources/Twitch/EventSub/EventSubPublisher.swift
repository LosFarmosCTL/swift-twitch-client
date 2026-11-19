#if canImport(Combine)
  import Combine
  import Foundation

  internal struct EventSubPublisher<Output: Sendable>: Combine.Publisher {
    typealias Failure = any Error
    typealias Start =
      @Sendable (
        @escaping @Sendable (EventSubListenerEvent<Output>) -> Void
      ) async throws -> TwitchCancellable

    let start: Start

    func receive<S: Combine.Subscriber>(subscriber: S)
    where S.Input == Output, S.Failure == Failure {
      subscriber.receive(
        subscription: EventSubPublisherSubscription(subscriber, start: start))
    }
  }

  // Combine calls request/cancel synchronously from arbitrary threads. Every mutable
  // field and downstream call is protected by the recursive lock (downstream may
  // synchronously reenter request/cancel). No lock is held across an await.
  private final class EventSubPublisherSubscription<Output: Sendable>: Combine
      .Subscription,
    @unchecked Sendable
  {
    private let lock = NSRecursiveLock()
    private let start: EventSubPublisher<Output>.Start

    private var downstream: AnySubscriber<Output, any Error>?
    private var demand: Subscribers.Demand = .none
    private var registrationTask: Task<Void, Never>?
    private var registration: TwitchCancellable?

    init<S: Combine.Subscriber>(
      _ downstream: S,
      start: @escaping EventSubPublisher<Output>.Start
    ) where S.Input == Output, S.Failure == any Error {
      self.downstream = AnySubscriber(downstream)
      self.start = start
    }

    deinit {
      registrationTask?.cancel()
      registration?.cancel()
    }

    func request(_ demand: Subscribers.Demand) {
      guard demand > .none else { return }

      lock.withLock {
        guard downstream != nil else { return }
        self.demand += demand

        guard registrationTask == nil, registration == nil else { return }
        registrationTask = startRegistration()
      }
    }

    func cancel() {
      let (registrationTask, registration) = lock.withLock {
        downstream = nil
        let resources = (self.registrationTask, self.registration)
        self.registrationTask = nil
        self.registration = nil
        return resources
      }

      registrationTask?.cancel()
      registration?.cancel()
    }

    private func startRegistration() -> Task<Void, Never> {
      Task { [weak self, start] in
        do {
          let handle = try await start { [weak self] event in self?.receive(event) }

          guard let self else {
            handle.cancel()
            return
          }
          self.storeRegistration(handle)
        } catch {
          self?.finish(.failure(error))
        }
      }
    }

    private func storeRegistration(_ handle: TwitchCancellable) {
      let cancelled = lock.withLock {
        registrationTask = nil
        guard downstream != nil else { return true }
        registration = handle
        return false
      }

      // Downstream can cancel before the registration returns its handle.
      if cancelled { handle.cancel() }
    }

    private func receive(_ event: EventSubListenerEvent<Output>) {
      switch event {
      case .event(let value):
        lock.withLock {
          guard let downstream, demand > .none else { return }

          demand -= 1
          let additional = downstream.receive(value)
          if self.downstream != nil { demand += additional }
        }
      case .finished: finish(.finished)
      case .failure(let error): finish(.failure(error))
      }
    }

    private func finish(_ completion: Subscribers.Completion<any Error>) {
      lock.withLock {
        guard let downstream else { return }

        self.downstream = nil
        downstream.receive(completion: completion)
      }
      cancel()
    }
  }
#endif
