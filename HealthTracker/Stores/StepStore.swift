import HealthKit

final class StepStore: BaseStore, MetricStorable {
	typealias Context = StepStoreContext

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
