import SwiftUI

@main
struct HealthTrackerApp: App {
	private let metricStore = MetricStore()

	var body: some Scene {
		WindowGroup {
			DashboardScreenView()
				.environment(self.metricStore)
		}
	}
}
