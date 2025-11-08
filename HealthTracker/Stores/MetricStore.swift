import HealthKit
import Observation
import OrderedCollections

@Observable
final class MetricStore {
	// MARK: - Stored Properties

	let healthKitService = HealthKitService()

	var stepDiscreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var weightDiscreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var stepAverageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()
	var weightDiffAverageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	// MARK: - Computed Properties

	var averageSteps: Double {
		return self.stepDiscreteMetricByDate.values.lazy.map { $0.value }.average ?? 0
	}

	var averageWeight: Double {
		return self.weightDiscreteMetricByDate.values.lazy.map { $0.value }.average ?? 0
	}

	var minimumWeight: Double {
		return self.weightDiscreteMetricByDate.values.lazy.map { $0.value }.min() ?? 0
	}

	// MARK: - Fetching

	func fetchMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.fetchStepMetrics() }
			group.addTask { try await self.fetchWeightMetrics() }

			try await group.waitForAll()
		}
	}

	private func fetchStepMetrics() async throws -> Void {
		let statistics = try await self.healthKitService.fetchStepStatistics(daysAgo: 28)

		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		self.stepDiscreteMetricByDate =
			statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
				let discreteMetric = DiscreteMetric(
					date: statistic.startDate,
					value: statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0,
				)

				dictionary[statistic.startDate] = discreteMetric
			}

		self.stepAverageMetricByWeekday = AverageMetric.calculate(
			from: self.stepDiscreteMetricByDate.values,
		)
	}

	private func fetchWeightMetrics() async throws -> Void {
		let statistics = try await self.healthKitService.fetchWeightStatistics(daysAgo: 28)

		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		self.weightDiscreteMetricByDate =
			statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
				let discreteMetric = DiscreteMetric(
					date: statistic.startDate,
					value: statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0,
				)

				dictionary[statistic.startDate] = discreteMetric
			}

		self.weightDiffAverageMetricByWeekday = AverageMetric.calculateDifferences(
			from: self.weightDiscreteMetricByDate.values,
		)
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

	func createFakeMetrics() async throws -> Void {
		try await self.healthKitService.createFakeSamples(daysAgo: 28)
	}
}
