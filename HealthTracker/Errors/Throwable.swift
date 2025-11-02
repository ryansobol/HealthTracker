import SwiftUI

protocol Throwable: Error {
	var errorDescription: String { get }

	var failureReason: String { get }

	var recoverySuggestion: String? { get }

	associatedtype ActionsBody: View
	@ViewBuilder var actions: Self.ActionsBody { get }

	associatedtype MessageBody: View
	@ViewBuilder var message: Self.MessageBody { get }
}

extension Throwable {
	var fullMessage: String {
		return if let recoverySuggestion = self.recoverySuggestion {
			"\(self.failureReason)\n\n\(recoverySuggestion)"
		}
		else {
			self.failureReason
		}
	}
}
