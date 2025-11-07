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

	var averageStepCount: Double {
		let stepDiscreteMetrics = self.stepDiscreteMetricByDate.values

		guard !stepDiscreteMetrics.isEmpty else {
			return 0
		}

		return stepDiscreteMetrics.reduce(0) { $0 + $1.value } / Double(stepDiscreteMetrics.count)
	}

	var averageWeightDifference: Double {
		let weightDiffAverageMetrics = self.weightDiffAverageMetricByWeekday.values

		guard !weightDiffAverageMetrics.isEmpty else {
			return 0
		}

		return weightDiffAverageMetrics
			.reduce(0) { $0 + $1.value } / Double(weightDiffAverageMetrics.count)
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
		let statistics = try await self.healthKitService.fetchStepStatistics()

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
		let statistics = try await self.healthKitService.fetchWeightStatistics()

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
			try await self.healthKitService.createStepSample(
				metricType: metricType,
				date: date,
				value: value,
			)

			try await self.fetchStepMetrics()

		case .weight:
			try await self.healthKitService.createWeightSample(
				metricType: metricType,
				date: date,
				value: value,
			)

			try await self.fetchWeightMetrics()
		}
	}

	func createFakeMetrics() async throws -> Void {
		try await self.healthKitService.createFakeSamples()
	}
}
