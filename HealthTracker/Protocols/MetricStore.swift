import Foundation
import OrderedCollections

protocol MetricStore {
	var discreteMetricByDate: OrderedDictionary<Date, DiscreteMetric> { get }
	var averageMetricByWeekday: OrderedDictionary<Weekday, AverageMetric> { get }

	func fetchMetrics(daysAgo: Int) async throws -> Void
	func createFakeMetrics(daysAgo: Int) async throws -> Void
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
