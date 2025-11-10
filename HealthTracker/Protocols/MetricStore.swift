import Foundation
import HealthKit
import OrderedCollections

protocol MetricStore: AnyObject {
	var healthKitService: HealthKitService { get }

	var discreteMetricByDate: OrderedDictionary<Date, DiscreteMetric> { get set }

	func deriveDiscreteMetricByDate(from statistics: some Collection<HKStatistics>)
		-> OrderedDictionary<Date, DiscreteMetric>

	var averageMetricByWeekday: OrderedDictionary<Weekday, AverageMetric> { get set }

	func deriveAverageMetricByWeekday(from discreteMetrics: some Collection<DiscreteMetric>)
		-> OrderedDictionary<Weekday, AverageMetric>
}

extension MetricStore {
	func fetchMetrics(daysAgo: Int = 28) async throws -> Void {
		let statistics = try await self.healthKitService.fetchStatistics(daysAgo: daysAgo)

		self.discreteMetricByDate = self.deriveDiscreteMetricByDate(from: statistics)

		self.averageMetricByWeekday = self.deriveAverageMetricByWeekday(
			from: self.discreteMetricByDate.values,
		)
	}

	func createMetric(date: Date, value: Double) async throws -> Void {
		try await self.healthKitService.createSample(date: date, value: value)
	}

	func createFakeMetrics(daysAgo: Int = 28) async throws -> Void {
		try await self.healthKitService.createFakeSamples(daysAgo: daysAgo)
	}
}

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
