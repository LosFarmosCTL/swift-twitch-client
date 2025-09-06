public struct CharityDonationEvent: Event {
  public let id: String
  public let campaignID: String

  public let broadcasterID: String
  public let broadcasterLogin: String
  public let broadcasterName: String

  public let userID: String
  public let userLogin: String
  public let userName: String

  public let charityName: String
  public let charityDescription: String
  public let charityLogo: String
  public let charityWebsite: String

  public let amount: CharityAmount

  enum CodingKeys: String, CodingKey {
    case id
    case campaignID = "campaignId"

    case broadcasterID = "broadcasterUserId"
    case broadcasterLogin = "broadcasterUserLogin"
    case broadcasterName = "broadcasterUserName"

    case userID = "userId"
    case userLogin = "userLogin"
    case userName = "userName"

    case charityName, charityDescription, charityLogo, charityWebsite

    case amount
  }

  public struct CharityAmount: Decodable, Sendable {
    public let value: Int
    public let decimalPlaces: Int
    public let currency: String
  }
}
