import SwiftUI

@main
struct HealthTrackerApp: App {
	private let healthKitManager = HealthKitManager()

	var body: some Scene {
		WindowGroup {
			DashboardView()
				.environment(self.healthKitManager)
		}
	}
}
