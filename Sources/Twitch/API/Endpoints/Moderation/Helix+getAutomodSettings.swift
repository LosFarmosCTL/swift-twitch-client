import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func getAutomodSettings(broadcasterId: String) async throws -> AutomodSettings {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterId), ("moderator_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<AutomodSettings>?) = try await self.request(
      .get("moderation/automod/settings"), with: queryItems)

    guard let settings = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return settings
  }
}

public struct AutomodSettings: Decodable {
  let broadcasterID: String
  let moderatorID: String
  let overallLevel: Int?

  let disability: Int
  let aggression: Int
  let sexualitySexOrGender: Int
  let misogyny: Int
  let bullying: Int
  let swearing: Int
  let raceEthnicityOrReligion: Int
  let sexBasedTerms: Int

  enum CodingKeys: String, CodingKey {
    case broadcasterID = "broadcaster_id"
    case moderatorID = "moderator_id"
    case overallLevel = "overall_level"

    case disability
    case aggression
    case sexualitySexOrGender = "sexuality_sex_or_gender"
    case misogyny
    case bullying
    case swearing
    case raceEthnicityOrReligion = "race_ethnicity_or_religion"
    case sexBasedTerms = "sex_based_terms"
  }
}
