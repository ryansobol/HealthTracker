import SwiftUI

enum AppError {
	case caught(underlyingError: any Error)
	case invalidMetricValue(metricType: MetricType, value: String)
	case sharingNotAuthorized(metricType: MetricType)
}

// MARK: - Explainable

extension AppError: Explainable {
	var errorDescription: String {
		return switch self {
		case .caught:
			"Error"

		case let .invalidMetricValue(metricType, _):
			"Invalid \(metricType)"

		case let .sharingNotAuthorized(metricType):
			"\(metricType) Sharing Not Authorized"
		}
	}

	var failureReason: String {
		return switch self {
		case .caught:
			"The app encountered an unexpected error."

		case let .invalidMetricValue(metricType, value):
			"\(value) is not a valid \(metricType)."

		case let .sharingNotAuthorized(metricType):
			"The app has not been authorization to share \(metricType) data with HealthKit."
		}
	}

	var recoverySuggestion: String {
		return switch self {
		case .caught:
			"Try performing the action again. If the error persists, try restarting the app."

		case .invalidMetricValue:
			"Try entering a number greater than zero."

		case .sharingNotAuthorized:
			"You can authorize sharing by going to Settings > Health > Data Access & Devices."
		}
	}
}

// MARK: - Alertable

extension AppError: Alertable {
	var title: String {
		return self.errorDescription
	}

	var actions: some View {
		switch self {
		case .caught, .invalidMetricValue:
			EmptyView()

		case .sharingNotAuthorized:
			Button("Settings") {
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			}

			Button("Cancel", role: .cancel) {}
		}
	}

	var message: some View {
		Text("\(self.failureReason)\n\n\(self.recoverySuggestion)")
	}
}
