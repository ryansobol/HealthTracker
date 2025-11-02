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
	/// logger.debug(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func debug(_ error: some Throwable, _ message: String = "") {
		self.debug("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and an info message to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.info(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func info(_ error: some Throwable, _ message: String = "") {
		self.info("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a notice to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.notice(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func notice(_ error: some Throwable, _ message: String = "") {
		self.notice("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a warning to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.warning(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func warning(_ error: some Throwable, _ message: String = "") {
		self.warning("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and an error message to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.error(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func error(_ error: some Throwable, _ message: String = "") {
		self.error("\(self.prepareMessage(message))\(error.errorDescription)")
	}

	/// Writes an error description and a fault to the log.
	///
	/// ## Usage
	///
	/// ```swift
	/// let logger = Logger()
	///
	/// logger.fault(error, "Boom")
	/// ```
	///
	/// - Parameters:
	///   - error: Extract the description from this error
	///   - message: The optional message to include
	func fault(_ error: some Throwable, _ message: String = "") {
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
