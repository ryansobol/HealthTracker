import HealthKit
import Observation
import OrderedCollections

@Observable
final class StepStore: MetricStore {
	// MARK: - Type aliases

	typealias Context = StepStoreContext

	// MARK: - Stored Properties

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(store: hkHealthStore, context: Context.serviceContext)
	}

	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()
}
