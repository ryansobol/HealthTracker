import OSLog

private let subsystem = Bundle.main.bundleIdentifier!

extension Logger {
	static var dashboardView: Self {
		return Logger(subsystem: subsystem, category: "DashboardView")
	}

	static var discreteMetricListView: Self {
		return Logger(subsystem: subsystem, category: "DiscreteMetricListView")
	}

	static var healthKitManager: Self {
		return Logger(subsystem: subsystem, category: "HealthKitManager")
	}
}
