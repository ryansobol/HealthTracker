protocol ExplainedError: Error {
	var errorDescription: String { get }

	var failureReason: String { get }

	var recoverySuggestion: String { get }
}
