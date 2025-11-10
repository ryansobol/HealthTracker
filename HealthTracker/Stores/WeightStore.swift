import HealthKit
import Observation
import OrderedCollections

@Observable
final class WeightStore: MetricStore {
	typealias Context = WeightStoreContext

	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
