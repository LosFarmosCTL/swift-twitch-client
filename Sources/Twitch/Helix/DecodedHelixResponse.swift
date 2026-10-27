import Foundation

internal struct DecodedHelixResponse<T: Decodable> {
  let data: [T]

  let pagination: Pagination?
  let points: Int?
  let template: String?
  let total: Int?
  let totalCost: Int?
  let maxTotalCost: Int?
  let errors: [Self.Error]?
  let dateRange: DateRange?

  let rawData: Data

  internal struct Pagination: Decodable { let cursor: String? }

  internal struct Error: Decodable, Sendable {
    let id: String
    let message: String
    let code: String
  }

  internal struct DateRange: Decodable {
    let startedAt: Date?
    let endedAt: Date?
  }
}

// NOTE: decode actual payload first so we can include raw data in response
internal struct HelixResponsePayload<T: Decodable>: Decodable {
  let data: [T]
  let pagination: DecodedHelixResponse<T>.Pagination?
  let points: Int?
  let template: String?
  let total: Int?
  let totalCost: Int?
  let maxTotalCost: Int?
  let errors: [DecodedHelixResponse<T>.Error]?
  let dateRange: DecodedHelixResponse<T>.DateRange?

  enum CodingKeys: String, CodingKey {
    case data
    case pagination
    case points
    case template
    case total
    case totalCost
    case maxTotalCost
    case errors
    case dateRange
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    if let data = try? container.decode([T].self, forKey: .data) {
      self.data = data
    } else if let single = try? container.decode(T.self, forKey: .data) {
      self.data = [single]
    } else {
      throw DecodingError.dataCorruptedError(
        forKey: .data, in: container,
        debugDescription: "Expected array or object for data.")
    }

    let paginationDecoder = try? container.superDecoder(forKey: .pagination)
    if let paginationDecoder,
      let pagination = try? DecodedHelixResponse<T>.Pagination(from: paginationDecoder)
    {
      self.pagination = pagination
    } else if let paginationDecoder,
      let cursor = try? String(from: paginationDecoder)
    {
      self.pagination = DecodedHelixResponse.Pagination(cursor: cursor)
    } else {
      self.pagination = nil
    }

    self.points = try container.decodeIfPresent(Int.self, forKey: .points)
    self.template = try container.decodeIfPresent(String.self, forKey: .template)
    self.total = try container.decodeIfPresent(Int.self, forKey: .total)
    self.totalCost = try container.decodeIfPresent(Int.self, forKey: .totalCost)
    self.maxTotalCost = try container.decodeIfPresent(Int.self, forKey: .maxTotalCost)
    self.errors = try container.decodeIfPresent(
      [DecodedHelixResponse.Error].self, forKey: .errors)

    self.dateRange = try container.decodeIfPresent(
      DecodedHelixResponse.DateRange.self, forKey: .dateRange)
  }
}

extension DecodedHelixResponse {
  internal init(payload: HelixResponsePayload<T>, rawData: Data) {
    self.data = payload.data
    self.pagination = payload.pagination
    self.points = payload.points
    self.template = payload.template
    self.total = payload.total
    self.totalCost = payload.totalCost
    self.maxTotalCost = payload.maxTotalCost
    self.errors = payload.errors
    self.dateRange = payload.dateRange

    self.rawData = rawData
  }
}

internal struct HelixErrorResponse: Sendable, Decodable {
  let error: String
  let status: Int
  let message: String
}

/// A placeholder payload type for endpoints without response data.
public struct EmptyResponse: Sendable, Decodable {}
