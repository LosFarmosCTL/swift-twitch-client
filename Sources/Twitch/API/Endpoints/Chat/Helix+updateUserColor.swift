import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func updateUserColor(color: HelixColor) async throws {
    let queryItems = self.makeQueryItems(
      ("user_id", self.authenticatedUserId), ("color", color.rawValue))

    _ =
      try await self.request(.put("chat/color"), with: queryItems) as (_, HelixData<Int>?)
  }
}

public enum HelixColor {
  case blue, blueViolet, cadetBlue, chocolate, coral, dodgerBlue, firebrick, goldenRod,
    green, hotPink, orangeRed, red, seaGreen, springGreen, yellowGreen
  case customHex(_ hexValue: String)

  public var rawValue: String {
    switch self {
    case .blue: return "blue"
    case .blueViolet: return "blue_violet"
    case .cadetBlue: return "cadet_blue"
    case .chocolate: return "chocolate"
    case .coral: return "coral"
    case .dodgerBlue: return "dodger_blue"
    case .firebrick: return "firebrick"
    case .goldenRod: return "goldenrod"
    case .green: return "green"
    case .hotPink: return "hot_pink"
    case .orangeRed: return "orange_red"
    case .red: return "red"
    case .seaGreen: return "sea_green"
    case .springGreen: return "spring_green"
    case .yellowGreen: return "yellow_green"
    case .customHex(let hexValue): return hexValue
    }
  }
}
