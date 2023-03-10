public struct Sub {
  public let rawIRCTags: [String: String]
  public let rawIRCMessage: String

  public let systemMessage: String
  public let message: ChatMessage

  public let channelName: String

  public let cumulativeMonths: Int
  public let months: Int
  public let multimonthDuration: Int
  public let multimonthTenure: Int
  public let streakMonths: Int?

  public let subType: SubType
  public let subPlanName: String

  public let gifted: Bool
  public let previouslyGifted: Bool

  public enum SubType {
    case prime
    case tier1
    case tier2
    case tier3

    case unknown(type: String)

    internal init(type: String) {
      switch type {
      case "Prime": self = .prime
      case "1000": self = .tier1
      case "2000": self = .tier2
      case "3000": self = .tier3
      default: self = .unknown(type: type)
      }
    }
  }
}
