/// An explicit cancellation handle returned by callback-based client APIs.
///
/// Methods such as ``TwitchClient/helixTask(for:completionHandler:)``,
/// ``TwitchClient/eventListener(for:callback:)``, and
/// ``TwitchClient/ircMessageListener(_:)`` return a `TwitchCancellable` so you can cancel
/// the underlying request or unregister an observer.
///
/// - Important: Releasing or dropping a `TwitchCancellable` does **not** cancel the
///   associated work—you must call ``cancel()`` explicitly. Copies share the same
///   cancellation closure, and repeated calls invoke it again.
public struct TwitchCancellable: Sendable {
  private let onCancel: @Sendable () -> Void

  /// Creates a handle that invokes a closure whenever ``cancel()`` is called.
  ///
  /// - Parameter onCancel: The closure to invoke each time ``cancel()`` is called.
  public init(_ onCancel: @escaping @Sendable () -> Void) {
    self.onCancel = onCancel
  }

  /// Invokes this handle's cancellation action.
  ///
  /// Cancellation is cooperative and may schedule asynchronous cleanup (such as deleting
  /// an EventSub subscription once its last observer leaves). Calling `cancel()` more
  /// than once invokes the stored closure each time; the handle itself does not guard
  /// against repeated calls.
  public func cancel() {
    onCancel()
  }
}
