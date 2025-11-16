import Foundation

struct DiscreteMetric: Identifiable, Equatable {
	let id = UUID()

	let date: Date
	let value: Double

	func accessibleValue(for metricType: MetricType) -> String {
		return switch metricType {
		case .step:
			"'\(self.value.formatted(.step))' \(metricType.title)"

		case .weight:
			"'\(self.value.formatted(.weight))' \(metricType.unitName)"
		}
	}
}
