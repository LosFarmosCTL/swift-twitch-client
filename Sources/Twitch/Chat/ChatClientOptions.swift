import Foundation

public struct ChatClientOptions {
  public var joinTimeout: Duration = .seconds(5)
  public var partTimeout: Duration = .seconds(5)
  public var connectTimeout: Duration = .seconds(10)

  public init() {}
}
