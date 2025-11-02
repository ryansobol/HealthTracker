import OSLog

private let subsystem = Bundle.main.bundleIdentifier!

extension Logger {
	init(category: (some Any).Type) {
		self.init(subsystem: subsystem, category: String(describing: category))
	}
}

extension Logger {
	/// Writes an error description and a debug message to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.debug("Boom", for: error)
	/// logger.debug(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func debug(_ message: String = "", for error: some Explainable) {
		self.debug("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and an info message to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.info("Boom", for: error)
	/// logger.info(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func info(_ message: String = "", for error: some Explainable) {
		self.info("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a notice to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.notice("Boom", for: error)
	/// logger.notice(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func notice(_ message: String = "", for error: some Explainable) {
		self.notice("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a warning to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.warning("Boom", for: error)
	/// logger.warning(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func warning(_ message: String = "", for error: some Explainable) {
		self.warning("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and an error message to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.error("Boom", for: error)
	/// logger.error(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func error(_ message: String = "", for error: some Explainable) {
		self.error("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a fault to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.fault("Boom", for: error)
	/// logger.fault(for: error)
	/// ```
	///
	/// - Parameters:
	///   - message: The optional message to include
	///   - error: Extract the description from this error
	func fault(_ message: String = "", for error: some Explainable) {
		self.fault("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Prepares a log message by trimming and formatting it for use as a prefix
	///
	/// - If the message is empty (or only whitespace/punctuation), returns empty string
	/// - If the message has content, returns it trimmed with `":\n"` appended
	///
	/// Examples:
	/// - `""` → `""`
	/// - `"Boom"` → `"Boom:\n"`
	/// - `" Boom: "` → `"Boom:\n"`
	/// - `"  :  "` → `""`
	///
	/// - Parameter message: The original message to prepare
	/// - Returns: Empty string or formatted message ready to prefix an error description
	private func prepareMessage(_ message: String) -> String {
		let trimmed = message.trimmingCharacters(
			in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: ":")),
		)

		return trimmed.isEmpty ? "" : "\(trimmed):\n"
	}
}
