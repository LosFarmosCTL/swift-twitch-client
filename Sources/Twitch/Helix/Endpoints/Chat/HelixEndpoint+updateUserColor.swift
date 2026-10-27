import Foundation

extension HelixEndpoint {
  /// Changes the authenticated user’s chat name color.
  ///
  /// With a user access token, requires `user:manage:chat_color`.
  ///
  /// See the [Twitch reference](
  /// https://dev.twitch.tv/docs/api/reference/#update-user-chat-color
  /// ) for request limits and account requirements.
  ///
  /// The request uses the executing client’s user ID for `user_id`.
  ///
  /// - Parameters:
  ///   - color: The new chat name color to assign to the authenticated user.
  public static func updateUserColor(
    to color: HelixColor
  ) -> HelixEndpoint<EmptyResponse, EmptyResponse, HelixEndpointResponseTypes.Void> {
    .init(
      method: "PUT", path: "chat/color",
      authentication: .user,
      queryItems: { credentials in
        [
          ("user_id", try credentials.requireUser().id),
          ("color", color.rawValue),
        ]
      })
  }
}

/// The named chat colors and custom hexadecimal colors accepted by Twitch.
public enum HelixColor: Sendable {
  /// The blue chat color.
  case blue
  /// The blue violet color option.
  case blueViolet
  /// The cadet blue color option.
  case cadetBlue
  /// The chocolate color option.
  case chocolate
  /// The coral color option.
  case coral
  /// The dodger blue color option.
  case dodgerBlue
  /// The firebrick color option.
  case firebrick
  /// The golden rod color option.
  case goldenRod
  /// The green chat color.
  case green
  /// The hot pink color option.
  case hotPink
  /// The orange red color option.
  case orangeRed
  /// The red color option.
  case red
  /// The sea green color option.
  case seaGreen
  /// The spring green color option.
  case springGreen
  /// The yellow green color option.
  case yellowGreen
  /// A custom hexadecimal color string.
  case customHex(_ hexValue: String)

  /// The value used in Twitch request or response payloads.
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
