import SwiftUI

enum MetricStoreError {
	case invalid(value: String, for: MetricType)
}

// MARK: - ExplainedError

extension MetricStoreError: ExplainedError {
	var errorDescription: String {
		return switch self {
		case let .invalid(_, metricType):
			"Invalid \(metricType)"
		}
	}

	var failureReason: String {
		return switch self {
		case let .invalid(value, metricType):
			"\(value) is not a valid \(metricType)."
		}
	}

	var recoverySuggestion: String {
		return switch self {
		case .invalid:
			"Try entering a number greater than zero."
		}
	}
}

// MARK: - Alertable

extension MetricStoreError: Alertable {
	var title: String {
		return self.errorDescription
	}

	var actions: some View {
		switch self {
		case .invalid:
			EmptyView()
		}
	}

	var message: some View {
		Text("\(self.failureReason)\n\n\(self.recoverySuggestion)")
	}
}
