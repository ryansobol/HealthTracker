import HealthKit
import Observation

@Observable
final class HealthKitManager {
	let store = HKHealthStore()
	let types = Set([HKQuantityType(.stepCount), HKQuantityType(.bodyMass)])
}
