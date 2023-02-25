enum HelixError: Error {
  case missingClientID
  case non2XXStatusCode(Int)
}
