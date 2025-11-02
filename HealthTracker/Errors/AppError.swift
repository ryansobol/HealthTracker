import SwiftUI

enum AppError {
	case caught(underlyingError: any Error)
	case sharingNotAuthorized(metricType: MetricType)
}

extension AppError: Throwable {
	var errorDescription: String {
		return switch self {
		case .caught:
			"Error"

		case let .sharingNotAuthorized(metricType):
			"\(metricType) sharing not authorized"
		}
	}

	var failureReason: String {
		return switch self {
		case .caught:
			"An unexpected error occurred."

		case let .sharingNotAuthorized(metricType):
			"You have not authorization the app to share \(metricType) data with HealthKit."
		}
	}

	var recoverySuggestion: String? {
		return switch self {
		case .caught:
			nil

		case .sharingNotAuthorized:
			"You can authorize sharing by going to Settings > Health > Data Access & Devices."
		}
	}

	var actions: some View {
		switch self {
		case .caught:
			EmptyView()

		case .sharingNotAuthorized:
			Button("Settings") {
				UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
			}

			Button("Cancel", role: .cancel) {}
		}
	}

	var message: some View {
		Text(self.fullMessage)
	}
}
