/// A decodable, sendable notification payload delivered by EventSub.
public protocol Event: Decodable, Sendable {}

/// A notification without event-specific data. Decoding ignores the payload.
public struct VoidEvent: Event {
  public init(from _: any Decoder) throws {}
}
