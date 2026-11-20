/// Tracks a bounded window of IDs in arrival order.
internal struct RecentIDs<ID: Hashable> {
  private let capacity: Int
  private var order: [ID] = []
  private var ids: Set<ID> = []

  init(capacity: Int) { self.capacity = capacity }

  func contains(_ id: ID) -> Bool { ids.contains(id) }

  mutating func insert(_ id: ID) -> Bool {
    guard ids.insert(id).inserted else { return false }

    order.append(id)
    if order.count > capacity { ids.remove(order.removeFirst()) }

    return true
  }
}
