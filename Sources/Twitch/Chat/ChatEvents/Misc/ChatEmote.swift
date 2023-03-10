public struct ChatEmote {
  public let id: String
  public let positions: Range<Int>

  internal init?(from emoteString: String) {
    let emoteParts = emoteString.components(separatedBy: ":")
    guard emoteParts.count == 2 else { return nil }

    self.id = String(emoteParts[0])

    let positions = emoteParts[1].components(separatedBy: "-").compactMap(
      Int.init)

    guard positions.count == 2 else { return nil }

    self.positions = Range<Int>(
      uncheckedBounds: (lower: positions[0], upper: positions[1]))
  }
}
