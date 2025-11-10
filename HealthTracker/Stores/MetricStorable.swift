import Foundation
import HealthKit
import OrderedCollections

protocol MetricStorable: AnyObject {
	associatedtype Context: MetricStoreContextual

	var healthKitService: HealthKitService { get }

	var discreteMetricByDate: OrderedDictionary<Date, DiscreteMetric> { get set }
	var averageMetricByWeekday: OrderedDictionary<Weekday, AverageMetric> { get set }
}

// MARK: - MetricType

extension MetricStorable {
	var metricType: MetricType {
		return Context.metricType
	}
}

// MARK: - Fetching

extension MetricStorable {
	func fetchMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchStatistics(daysAgo: daysAgo)

		self.discreteMetricByDate = self.deriveDiscreteMetricByDate(from: statistics)

		self.averageMetricByWeekday = self.deriveAverageMetricByWeekday(
			from: Array(self.discreteMetricByDate.values),
		)
	}

	private func deriveDiscreteMetricByDate(from statisticsArray: [HKStatistics])
		-> OrderedDictionary<Date, DiscreteMetric>
	{
		let discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>(
			minimumCapacity: statisticsArray.count,
		)

		return statisticsArray.reduce(into: discreteMetricByDate) { dictionary, statistics in
			let discreteMetric = DiscreteMetric(
				date: statistics.startDate,
				value: Context.metricType.quantity(for: statistics),
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

extension MetricStorable {
	func createMetric(date: Date, value: Double) async throws -> Void {
		try await self.healthKitService.createSample(date: date, value: value)
	}

	func createFakeMetrics(daysAgo: Int = 28) async throws -> Void {
		let today = Date.now

		var emptySamples = [(date: Date, value: Double)]()

		emptySamples.reserveCapacity(daysAgo)

		let resultSamples = (0 ..< daysAgo).reduce(into: emptySamples) { samples, day in
			let date = Calendar.current.date(byAdding: .day, value: -day, to: today)!
			let value = Context.generateFakeValue(for: day)

			samples.append((date: date, value: value))
		}

		try await self.healthKitService.createSamples(resultSamples)
	}
}

// MARK: - Statistics

extension MetricStorable {
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
