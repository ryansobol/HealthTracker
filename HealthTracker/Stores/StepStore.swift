import HealthKit
import Observation
import OrderedCollections

@Observable
final class StepStore: MetricStore {
	// MARK: - Stored Properties

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(store: hkHealthStore, context: .steps)
	}

	let quantityType = HKQuantityType(.stepCount)

	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	// MARK: - Derivations

	func deriveDiscreteMetricByDate(from statistics: some Collection<HKStatistics>)
		-> OrderedDictionary<Date, DiscreteMetric>
	{
		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		return statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
			let discreteMetric = DiscreteMetric(
				date: statistic.startDate,
				value: statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0.0,
			)

			dictionary[discreteMetric.date] = discreteMetric
		}
	}

	func deriveAverageMetricByWeekday(from discreteMetrics: some Collection<DiscreteMetric>)
		-> OrderedDictionary<Weekday, AverageMetric>
	{
		return AverageMetric.calculate(from: discreteMetrics)
	}
}
