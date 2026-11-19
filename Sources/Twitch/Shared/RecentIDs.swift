/// Tracks a bounded window of IDs in arrival order.
internal struct RecentIDs {
  private let capacity: Int
  private var order: [String] = []
  private var ids: Set<String> = []

  init(capacity: Int) { self.capacity = capacity }

  mutating func insert(_ id: String) -> Bool {
    guard ids.insert(id).inserted else { return false }

    order.append(id)
    if order.count > capacity { ids.remove(order.removeFirst()) }

    return true
  }
}
