import HealthKit

final class StepStore: MetricStoreBase, MetricStorable {
	typealias Context = StepStoreContext

	let healthKitService: HealthKitService

	init(hkHealthStore: HKHealthStore = .init()) {
		self.healthKitService = HealthKitService(metricType: Context.metricType, store: hkHealthStore)
	}
}
