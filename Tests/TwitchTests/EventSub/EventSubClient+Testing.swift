@testable import Twitch

extension EventSubClient {
  var connectionCreationWaiterCount: Int { sessions.waiters.count }

  var subscriptionObserverCount: Int {
    subscriptions.values.reduce(0) { $0 + $1.observers.count }
  }

  var subscriptionSetupWaiterCount: Int {
    subscriptions.values.reduce(0) { count, subscription in
      switch subscription.phase {
      case .reserving, .posting: count + subscription.observers.count
      case .closing: count + (subscription.cleanupWaiters?.count ?? 0)
      case .active: count
      }
    }
  }
}
