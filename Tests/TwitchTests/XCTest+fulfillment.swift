#if os(Linux)
  import XCTest

  extension XCTestCase {
    func fulfillment(
      of expectations: [XCTestExpectation], timeout: TimeInterval,
      enforceOrder: Bool = false
    ) async {
      return await withCheckedContinuation { continuation in
        self.wait(for: expectations, timeout: timeout, enforceOrder: enforceOrder)
        continuation.resume()
      }
    }
  }
#endif
