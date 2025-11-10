import HealthKit

final class WeightStore: MetricStoreBase, MetricStorable {
	typealias Context = WeightStoreContext

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
