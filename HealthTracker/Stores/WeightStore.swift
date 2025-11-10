import HealthKit
import Observation
import OrderedCollections

@Observable
final class WeightStore: MetricStore {
	// MARK: - Type aliases

	typealias Context = WeightStoreContext

	// MARK: - Stored Properties

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(store: hkHealthStore, context: .weight)
	}

	let quantityType = HKQuantityType(.bodyMass)

	var discreteMetricByDate = OrderedDictionary<Date, DiscreteMetric>()

	var averageMetricByWeekday = OrderedDictionary<Weekday, AverageMetric>()
}
