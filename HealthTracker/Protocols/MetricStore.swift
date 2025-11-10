import Foundation
import HealthKit
import OrderedCollections

protocol MetricStore: AnyObject {
	associatedtype Context: StoreContext

	var healthKitService: HealthKitService { get }

	var discreteMetricByDate: OrderedDictionary<Date, DiscreteMetric> { get set }

	var averageMetricByWeekday: OrderedDictionary<Weekday, AverageMetric> { get set }
}

// MARK: - Fetching

extension MetricStore {
	func fetchMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchStatistics(daysAgo: daysAgo)

		self.discreteMetricByDate = self.deriveDiscreteMetricByDate(from: statistics)

		self.averageMetricByWeekday = self.deriveAverageMetricByWeekday(
			from: Array(self.discreteMetricByDate.values),
		)
	}

	private func deriveDiscreteMetricByDate(from statistics: [HKStatistics])
		-> OrderedDictionary<Date, DiscreteMetric>
	{
		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statistics.count,
		)

		return statistics.reduce(into: discreteMetricByDate) { dictionary, statistic in
			let discreteMetric = DiscreteMetric(
				date: statistic.startDate,
				value: Context.selectQuantity(from: statistic),
			)

			dictionary[discreteMetric.date] = discreteMetric
		}
	}

	func deriveAverageMetricByWeekday(from discreteMetrics: [DiscreteMetric])
		-> OrderedDictionary<Weekday, AverageMetric>
	{
		let discreteMetricsForAveraging = Context.selectDiscreteMetricsForAveraging(
			from: discreteMetrics,
		)

		return OrderedDictionary(grouping: discreteMetricsForAveraging) { $0.date.weekday }
			.mapValues { AverageMetric(weekday: $0, discreteMetrics: $1) }
			.sorted()
	}
}

// MARK: - Creation

extension MetricStore {
	func createMetric(date: Date, value: Double) async throws -> Void {
		try await self.healthKitService.createSample(date: date, value: value)
	}

	func createFakeMetrics(daysAgo: Int = 28) async throws -> Void {
		try await self.healthKitService.createFakeSamples(daysAgo: daysAgo)
	}
}

// MARK: - Statistics

extension MetricStore {
	var discreteMetricAverage: Double {
		return self.discreteMetricByDate.averageValue
	}

	var discreteMetricMaximum: Double {
		return self.discreteMetricByDate.maximumValue
	}

	var discreteMetricMinimum: Double {
		return self.discreteMetricByDate.minimumValue
	}

	var averageMetricAverage: Double {
		return self.averageMetricByWeekday.averageValue
	}

	var averageMetricMaximum: Double {
		return self.averageMetricByWeekday.maximumValue
	}

	var averageMetricMinimum: Double {
		return self.averageMetricByWeekday.minimumValue
	}
}
