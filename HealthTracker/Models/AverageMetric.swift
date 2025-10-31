import Foundation

struct AverageMetric: Identifiable {
	let id = UUID()

	let weekday: Weekday
	let value: Double

	init(weekday: Weekday, healthMetrics: [HealthMetric]) {
		self.weekday = weekday
		self.value = healthMetrics.reduce(0) { $0 + $1.value } / Double(healthMetrics.count)
	}

	static func calculate(from healthMetrics: [HealthMetric]) -> [Self] {
		return Dictionary(grouping: healthMetrics) { $0.date.weekday }
			.map { Self(weekday: $0, healthMetrics: $1) }
			.sorted { $0.weekday < $1.weekday }
	}

	static func calculateDifferences(from healthMetrics: [HealthMetric]) -> [Self] {
		let differences = zip(healthMetrics.dropFirst(), healthMetrics).map { current, previous in
			HealthMetric(date: current.date, value: current.value - previous.value)
		}

		return Self.calculate(from: differences)
	}
}
