import Foundation
import Testing

@testable import Twitch

struct HelixResponseRequirementTests {
  @Test
  func firstDataReturnsFirstElement() throws {
    let response = makeResponse(data: ["first", "second"])

    #expect(try response.requireFirst() == "first")
  }

  @Test
  func firstDataThrowsWithRawResponseWhenEmpty() {
    let rawData = Data("raw-response".utf8)
    let response = makeResponse(data: [String](), rawData: rawData)

    do {
      _ = try response.requireFirst()
      Issue.record("Expected an empty response to throw.")
    } catch HelixError.noDataInResponse(let responseData) {
      #expect(responseData == rawData)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }

  @Test
  func requiredMetadataReturnsValue() throws {
    let response = makeResponse(data: ["value"], total: 42)

    #expect(try response.require(\.total) == 42)
  }

  @Test
  func requiredMetadataThrowsWithRawResponseWhenMissing() {
    let rawData = Data("raw-response".utf8)
    let response = makeResponse(data: ["value"], rawData: rawData)

    do {
      _ = try response.require(\.total)
      Issue.record("Expected missing metadata to throw.")
    } catch HelixError.missingDataInResponse(let responseData) {
      #expect(responseData == rawData)
    } catch {
      Issue.record("Unexpected error: \(error)")
    }
  }
}

private func makeResponse<T: Decodable>(
  data: [T],
  total: Int? = nil,
  rawData: Data = Data()
) -> HelixResponse<T> {
  HelixResponse(
    data: data,
    pagination: nil,
    points: nil,
    template: nil,
    total: total,
    totalCost: nil,
    maxTotalCost: nil,
    errors: nil,
    dateRange: nil,
    rawData: rawData)
}
