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
    // Twitch uses empty strings when there is no reporting window.
    @NilOnTypeMismatch var startedAt: Date?
    @NilOnTypeMismatch var endedAt: Date?
  }
}

// NOTE: decode actual payload first so we can include raw data in response
internal struct HelixResponsePayload<T: Decodable>: Decodable {
  let data: [T]
  let pagination: DecodedHelixResponse<T>.Pagination?
  let paginationFailure: (any Error)?
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

    // An explicit null is Twitch's empty-result sentinel for some operations
    // (for example, Get User Chat Color). Missing or malformed data still fails.
    if try container.decodeNil(forKey: .data) {
      self.data = []
    } else {
      do {
        self.data = try container.decode([T].self, forKey: .data)
      } catch is CancellationError {
        throw CancellationError()
      } catch let arrayError {
        do {
          self.data = [try container.decode(T.self, forKey: .data)]
        } catch is CancellationError {
          throw CancellationError()
        } catch {
          // A mismatch at `data` means the array decoder could not enter the value.
          // Once it reaches an element, its error describes that element's failure.
          if case DecodingError.typeMismatch(_, let context) = arrayError,
            context.codingPath.count == container.codingPath.count + 1
          {
            throw error
          }
          throw arrayError
        }
      }
    }

    var pagination: DecodedHelixResponse<T>.Pagination?
    var paginationFailure: (any Error)?
    if container.contains(.pagination), try !container.decodeNil(forKey: .pagination) {
      let paginationDecoder = try container.superDecoder(forKey: .pagination)
      do {
        pagination = try DecodedHelixResponse<T>.Pagination(from: paginationDecoder)
      } catch {
        if let cursor = try? String(from: paginationDecoder) {
          pagination = .init(cursor: cursor.isEmpty ? nil : cursor)
        } else {
          paginationFailure = error
        }
      }
    }

    self.pagination = pagination
    self.paginationFailure = paginationFailure

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
