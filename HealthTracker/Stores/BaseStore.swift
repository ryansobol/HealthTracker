import Foundation
import Observation
import OrderedCollections

@Observable
class BaseStore {
	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	init() {}
}
