import Foundation
import OrderedCollections

struct AverageMetric: Identifiable, Equatable {
	let id = UUID()

	let weekday: Weekday
	let value: Double

	init(weekday: Weekday, discreteMetrics: [DiscreteMetric]) {
		self.weekday = weekday
		self.value = discreteMetrics.reduce(0) { $0 + $1.value } / Double(discreteMetrics.count)
	}

	func accessibleValue(for metricType: MetricType) -> String{
		return switch metricType {
		case .step:
			"'\(self.value.formatted(.step))' \(metricType.title)"

		case .weight:
			"'\(self.value.formatted(.weightChange.sign(strategy: .always())))' \(metricType.unitName)"
		}
	}
}
