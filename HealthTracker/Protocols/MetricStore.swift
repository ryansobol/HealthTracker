import Foundation
import OrderedCollections

protocol MetricStore {
	var discreteMetricByDate: OrderedDictionary<Date, DiscreteMetric> { get }
	var averageMetricByWeekday: OrderedDictionary<Weekday, AverageMetric> { get }

	var average: Double { get }
	var maximum: Double { get }
	var minimum: Double { get }

	func fetchMetrics(daysAgo: Int) async throws -> Void
	func createFakeMetrics(daysAgo: Int) async throws -> Void
}
