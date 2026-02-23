import Foundation

internal struct HelixResponse<T: Decodable> {
  let data: [T]

  let pagination: Pagination?
  let points: Int?
  let template: String?
  let total: Int?
  let totalCost: Int?
  let maxTotalCost: Int?

  let rawData: Data

  internal struct Pagination: Decodable { let cursor: String? }
}

// NOTE: decode actual payload first so we can include raw data in response
internal struct HelixResponsePayload<T: Decodable>: Decodable {
  let data: [T]
  let pagination: HelixResponse<T>.Pagination?
  let points: Int?
  let template: String?
  let total: Int?
  let totalCost: Int?
  let maxTotalCost: Int?
}

extension HelixResponse {
  internal init(payload: HelixResponsePayload<T>, rawData: Data) {
    self.data = payload.data
    self.pagination = payload.pagination
    self.points = payload.points
    self.template = payload.template
    self.total = payload.total
    self.totalCost = payload.totalCost
    self.maxTotalCost = payload.maxTotalCost
    self.rawData = rawData
  }
}

internal struct HelixErrorResponse: Decodable {
  let error: String
  let status: Int
  let message: String
}

public struct EmptyResponse: Decodable {}
