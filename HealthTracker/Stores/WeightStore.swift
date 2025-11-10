import HealthKit

final class WeightStore: BaseStore, MetricStore {
	typealias Context = WeightStoreContext

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
