import SwiftUI

@main
struct HealthTrackerApp: App {
	private let metricStore = MetricStore()

	var body: some Scene {
		WindowGroup {
			DashboardView()
				.environment(self.metricStore)
		}
	}
}
