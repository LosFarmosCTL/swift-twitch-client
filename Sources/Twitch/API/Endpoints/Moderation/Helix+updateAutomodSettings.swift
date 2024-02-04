import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension Helix {
  public func updateAutomodSettings(forChannel broadcasterID: String, overall level: Int)
    async throws -> AutomodSettings
  {
    try await self.updateAutomodSettings(
      forChannel: broadcasterID, body: ["overall_level": level])
  }

  public func updateAutomodSettings(
    forChannel broadcasterID: String, settings: AutomodConfiguration
  ) async throws -> AutomodSettings {
    try await self.updateAutomodSettings(forChannel: broadcasterID, body: settings)
  }

  private func updateAutomodSettings(forChannel broadcasterID: String, body: Encodable)
    async throws -> AutomodSettings
  {
    let queryItems = self.makeQueryItems(
      ("broadcaster_id", broadcasterID), ("moderator_id", self.authenticatedUserId))

    let (rawResponse, result): (_, HelixData<AutomodSettings>?) = try await self.request(
      .put("moderation/automod/settings"), with: queryItems, jsonBody: body)
    guard let settings = result?.data.first else {
      throw HelixError.invalidResponse(rawResponse: rawResponse)
    }

    return settings
  }
}

public struct AutomodConfiguration: Encodable {
  let aggression: Int
  let bullying: Int
  let disability: Int
  let misogyny: Int
  let raceEthnicityOrReligion: Int
  let sexBasedTerms: Int
  let sexualitySexOrGender: Int
  let swearing: Int

  enum CodingKeys: String, CodingKey {
    case aggression, bullying, disability, misogyny, swearing

    case raceEthnicityOrReligion = "race_ethnicity_or_religion"
    case sexBasedTerms = "sex_based_terms"
    case sexualitySexOrGender = "sexuality_sex_or_gender"
  }
}
