import HealthKit
import Observation

@Observable
final class HealthKitManager {
	let store = HKHealthStore()
	let types = Set([HKQuantityType(.stepCount), HKQuantityType(.bodyMass)])

	func shouldRequestAuthorization() async throws -> Bool {
		let result = try await self.store.statusForAuthorizationRequest(
			toShare: self.types,
			read: self.types,
		)

		return result == .shouldRequest
	}
}
