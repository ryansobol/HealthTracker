import HealthKit
import Observation
import OrderedCollections

@Observable
final class StepStore: MetricStore {
	typealias Context = StepStoreContext

	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()
	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
