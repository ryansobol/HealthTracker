import Foundation
import OrderedCollections

struct AverageMetric: Identifiable {
	let id = UUID()

	let weekday: Weekday
	let value: Double

	init(weekday: Weekday, discreteMetrics: [DiscreteMetric]) {
		self.weekday = weekday
		self.value = discreteMetrics.reduce(0) { $0 + $1.value } / Double(discreteMetrics.count)
	}

	static func calculate(from discreteMetrics: some Sequence<DiscreteMetric>)
		-> OrderedDictionary<Weekday, Self>
	{
		return OrderedDictionary(grouping: discreteMetrics) { $0.date.weekday }
			.mapValues { Self(weekday: $0, discreteMetrics: $1) }
			.sorted()
	}

	static func calculateDifferences(from discreteMetrics: some Sequence<DiscreteMetric>)
		-> OrderedDictionary<Weekday, Self>
	{
		let differences = zip(discreteMetrics.dropFirst(), discreteMetrics).map { current, previous in
			DiscreteMetric(date: current.date, value: current.value - previous.value)
		}

		return Self.calculate(from: differences)
	}
}
