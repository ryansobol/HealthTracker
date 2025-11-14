import HealthKit
import SwiftUI

@main
struct HealthTrackerApp: App {
	let stepStore: StepStore
	let weightStore: WeightStore

	init() {
		let hkHealthStore = HKHealthStore()

		self.stepStore = StepStore(hkHealthStore: hkHealthStore)
		self.weightStore = WeightStore(hkHealthStore: hkHealthStore)
	}

	var body: some Scene {
		WindowGroup {
			DashboardScreenView()
				.environment(self.stepStore)
				.environment(self.weightStore)
		}
	}
}
