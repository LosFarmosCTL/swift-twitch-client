#if canImport(Combine)
  import Combine
  import Foundation

  internal struct EventSubPublisher<Output: Sendable>: Combine.Publisher {
    typealias Failure = any Error
    typealias Start =
      @Sendable (
        @escaping @Sendable (EventSubListenerEvent<Output>) -> Void
      ) async throws -> TwitchCancellable?

    let start: Start

    func receive<S: Combine.Subscriber>(subscriber: S)
    where S.Input == Output, S.Failure == Failure {
      subscriber.receive(
        subscription: EventSubPublisherSubscription(subscriber, start: start))
    }
  }

  // Combine calls request/cancel synchronously from arbitrary threads. State mutations are
  // serialized under the lock, while downstream value/completion delivery and cancellations
  // run outside the lock via a single FIFO drain loop to avoid lock-inversion deadlocks.
  private final class EventSubPublisherSubscription<Output: Sendable>: Combine
      .Subscription,
    @unchecked Sendable
  {
    private enum PendingItem {
      case value(Output)
      case completion(Subscribers.Completion<any Error>)
    }

    private enum DrainAction {
      case value(AnySubscriber<Output, any Error>, Output)
      case complete(
        AnySubscriber<Output, any Error>?, Subscribers.Completion<any Error>,
        Task<Void, Never>?, TwitchCancellable?)
      case stop
    }

    private let lock = NSLock()
    private let start: EventSubPublisher<Output>.Start

    private var downstream: AnySubscriber<Output, any Error>?
    private var demand: Subscribers.Demand = .none
    private var registrationTask: Task<Void, Never>?
    private var registration: TwitchCancellable?
    private var pending: [PendingItem] = []
    private var isDelivering = false

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
        pending.removeAll()
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
          guard let handle = try await start({ [weak self] event in self?.receive(event) }) else {
            self?.enqueue(.completion(.finished))
            return
          }

          guard let self else {
            handle.cancel()
            return
          }
          self.storeRegistration(handle)
        } catch {
          self?.enqueue(.completion(.failure(error)))
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
      case .event(let value): enqueue(.value(value))
      case .finished: enqueue(.completion(.finished))
      case .failure(let error): enqueue(.completion(.failure(error)))
      }
    }

    private func enqueue(_ item: PendingItem) {
      let shouldDrain = lock.withLock { () -> Bool in
        guard downstream != nil else { return false }
        if case .value = item, !isDelivering, demand == .none {
          return false
        }
        pending.append(item)
        if isDelivering { return false }
        isDelivering = true
        return true
      }

      if shouldDrain { drain() }
    }

    private func drain() {
      while true {
        let action: DrainAction = lock.withLock {
          while !pending.isEmpty {
            let next = pending.removeFirst()
            switch next {
            case .value(let value):
              guard let downstream, demand > .none else { continue }
              demand -= 1
              return .value(downstream, value)
            case .completion(let completion):
              return completeLocked(completion)
            }
          }
          isDelivering = false
          return .stop
        }

        switch action {
        case .value(let downstream, let value):
          let additional = downstream.receive(value)
          if additional > .none {
            lock.withLock {
              if self.downstream != nil { self.demand += additional }
            }
          }
        case .complete(let downstream, let completion, let registrationTask, let registration):
          downstream?.receive(completion: completion)
          registrationTask?.cancel()
          registration?.cancel()
          return
        case .stop:
          return
        }
      }
    }

    private func completeLocked(
      _ completion: Subscribers.Completion<any Error>
    ) -> DrainAction {
      let downstream = self.downstream
      let registrationTask = self.registrationTask
      let registration = self.registration
      self.downstream = nil
      self.registrationTask = nil
      self.registration = nil
      pending.removeAll()
      isDelivering = false
      return .complete(downstream, completion, registrationTask, registration)
    }
  }
#endif
