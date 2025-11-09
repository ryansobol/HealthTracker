import SwiftUI

@main
struct HealthTrackerApp: App {
	@Environment(\.hkHealthStore) private var hkHealthStore

	var body: some Scene {
		WindowGroup {
			DashboardScreenView()
				.environment(MetricStore())
				.environment(StepStore(hkHealthStore: self.hkHealthStore))
				.environment(WeightStore(hkHealthStore: self.hkHealthStore))
		}
	}
}
