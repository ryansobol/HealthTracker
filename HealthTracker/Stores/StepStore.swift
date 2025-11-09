import HealthKit
import Observation
import OrderedCollections

@Observable
final class StepStore {
	// MARK: - Stored Properties

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(hkHealthStore: hkHealthStore)
	}

	let quantityType = HKQuantityType(.stepCount)

	var stepDiscreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var stepAverageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	// MARK: - Computed Properties

	var averageSteps: Double {
		return self.stepDiscreteMetricByDate.averageValue
	}

	var maximumSteps: Double {
		return self.stepDiscreteMetricByDate.maximumValue
	}

	// MARK: - Fetching

	func fetchMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchStepStatistics(daysAgo: daysAgo)

		let (discreteMetricsByDate, averageMetricsByDate) = self.transform(
			statistics: statistics,
			metricType: .steps,
		)

		self.stepDiscreteMetricByDate = discreteMetricsByDate

		self.stepAverageMetricByWeekday = averageMetricsByDate
	}

	private func transform(statistics: [HKStatistics], metricType: MetricType)
		-> (
			discreteMetrics: OrderedDictionary<Date, DiscreteMetric>,
			averageMetrics: OrderedDictionary<Weekday, AverageMetric>,
		)
	{
		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		let discreteMetrics = statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
			let discreteMetric = DiscreteMetric(
				date: statistic.startDate,
				value: self.extractValue(from: statistic),
			)

			dictionary[statistic.startDate] = discreteMetric
		}

		let averageMetrics = self.calculateAverages(from: discreteMetrics.values)

		return (discreteMetrics, averageMetrics)
	}

	private func extractValue(from statistic: HKStatistics) -> Double {
		return statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0
	}

	private func calculateAverages(
		from discreteMetrics: OrderedDictionary<Date, DiscreteMetric>.Values,
	)
		-> OrderedDictionary<Weekday, AverageMetric>
	{
		return AverageMetric.calculate(from: discreteMetrics)
	}

	// MARK: - Creation

	func createMetric(date: Date, value: Double) async throws -> Void {
		try await self.healthKitService.createStepSample(date: date, value: value)

		try await self.fetchMetrics()
	}

	func createFakeMetrics(daysAgo: Int = 28) async throws -> Void {
		try await self.healthKitService.createFakeStepSamples(daysAgo: daysAgo)
	}
}
