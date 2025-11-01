import Foundation

struct AverageMetric: Identifiable {
	let id = UUID()

	let weekday: Weekday
	let value: Double

	init(weekday: Weekday, discreteMetrics: [DiscreteMetric]) {
		self.weekday = weekday
		self.value = discreteMetrics.reduce(0) { $0 + $1.value } / Double(discreteMetrics.count)
	}

	static func calculate(from discreteMetrics: [DiscreteMetric]) -> [Self] {
		return Dictionary(grouping: discreteMetrics) { $0.date.weekday }
			.map { Self(weekday: $0, discreteMetrics: $1) }
			.sorted { $0.weekday < $1.weekday }
	}

	static func calculateDifferences(from discreteMetrics: [DiscreteMetric]) -> [Self] {
		let differences = zip(discreteMetrics.dropFirst(), discreteMetrics).map { current, previous in
			DiscreteMetric(date: current.date, value: current.value - previous.value)
		}

		return Self.calculate(from: differences)
	}
}
