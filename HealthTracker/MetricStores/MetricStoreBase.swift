import Foundation
import Observation
import OrderedCollections

@Observable
class MetricStoreBase {
	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	init() {}
}
