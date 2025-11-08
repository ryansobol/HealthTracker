import HealthKit
import Observation
import OrderedCollections

@Observable
final class MetricStore {
	// MARK: - Configuration

	private struct Configuration {
		let calculateAverages: (OrderedDictionary<Date, DiscreteMetric>.Values)
			-> OrderedDictionary<Weekday, AverageMetric>

		let extractValue: (HKStatistics) -> Double

		static let steps = Configuration(
			calculateAverages: { discreteMetrics in
				AverageMetric.calculate(from: discreteMetrics)
			},
			extractValue: { statistic in
				statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0
			},
		)

		static let weight = Configuration(
			calculateAverages: { discreteMetrics in
				AverageMetric.calculateDifferences(from: discreteMetrics)
			},
			extractValue: { statistic in
				statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
			},
		)
	}

	// MARK: - Stored Properties

	private let configurations: [MetricType: Configuration] = [
		.steps: .steps,
		.weight: .weight,
	]

	let healthKitService = HealthKitService()

	var stepDiscreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var weightDiscreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var stepAverageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()
	var weightDiffAverageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	// MARK: - Computed Properties

	var averageSteps: Double {
		return self.stepDiscreteMetricByDate.averageValue
	}

	var averageWeight: Double {
		return self.weightDiscreteMetricByDate.averageValue
	}

	var minimumWeight: Double {
		return self.weightDiscreteMetricByDate.minimumValue
	}

	// MARK: - Fetching

	func fetchMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.fetchStepMetrics() }
			group.addTask { try await self.fetchWeightMetrics() }

			try await group.waitForAll()
		}
	}

	private func fetchStepMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchStepStatistics(daysAgo: daysAgo)

		let (discreteMetricsByDate, averageMetricsByDate) = self.transform(
			statistics: statistics,
			metricType: .steps,
		)

		self.stepDiscreteMetricByDate = discreteMetricsByDate

		self.stepAverageMetricByWeekday = averageMetricsByDate
	}

	private func fetchWeightMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchWeightStatistics(daysAgo: daysAgo)

		let (discreteMetricsByDate, averageMetricsByDate) = self.transform(
			statistics: statistics,
			metricType: .weight,
		)

		self.weightDiscreteMetricByDate = discreteMetricsByDate

		self.weightDiffAverageMetricByWeekday = averageMetricsByDate
	}

	private func transform(statistics: [HKStatistics], metricType: MetricType)
		-> (
			discreteMetrics: OrderedDictionary<Date, DiscreteMetric>,
			averageMetrics: OrderedDictionary<Weekday, AverageMetric>,
		)
	{
		guard let config = self.configurations[metricType] else {
			fatalError("No configuration for metric type: \(metricType)")
		}

		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		let discreteMetrics = statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
			let discreteMetric = DiscreteMetric(
				date: statistic.startDate,
				value: config.extractValue(statistic),
			)

			dictionary[statistic.startDate] = discreteMetric
		}

		let averageMetrics = config.calculateAverages(discreteMetrics.values)

		return (discreteMetrics, averageMetrics)
	}

	// MARK: - Creation

	func createMetric(metricType: MetricType, date: Date, value: Double) async throws -> Void {
		switch metricType {
		case .steps:
			try await self.healthKitService.createStepSample(date: date, value: value)

			try await self.fetchStepMetrics()

		case .weight:
			try await self.healthKitService.createWeightSample(date: date, value: value)

			try await self.fetchWeightMetrics()
		}
	}

	func createFakeMetrics(daysAgo: Int = 28) async throws -> Void {
		try await self.healthKitService.createFakeSamples(daysAgo: daysAgo)
	}
}
