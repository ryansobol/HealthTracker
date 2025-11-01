import Charts
import OSLog
import SwiftUI

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DashboardView")

struct DashboardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var isShowingPermissionPrimingSheet = false
	@State private var selectedMetricType = MetricType.steps

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					Picker("Selected Metric Type", selection: self.$selectedMetricType) {
						ForEach(MetricType.allCases) { metric in
							Text(metric.title)
						}
					}
					.pickerStyle(.segmented)

					switch self.selectedMetricType {
					case .steps:
						StepBarChart()

						StepPieChart()

					case .weight:
						WeightLineChart()

						WeightBarChart()
					}
				}
			}
			.padding()
			.navigationTitle("Dashboard")
			.navigationDestination(for: MetricType.self) { metric in
				DiscreteMetricListView(metricType: metric)
			}
		}
		.tint(self.selectedMetricType.tint)
		.fullScreenCover(isPresented: self.$isShowingPermissionPrimingSheet, onDismiss: {
			Task {
				do {
					try await self.healthKitManager.createFakeSamples()
					try await self.healthKitManager.fetchMetrics()
				}
				catch {
					logger.error("\(error)")
				}
			}
		}, content: {
			HealthKitPermissionPrimingView()
		})
		.task {
			do {
				try await self.healthKitManager.fetchMetrics()
			}
			catch AuthorizationError.authorizationRequestNecessary {
				self.isShowingPermissionPrimingSheet = true
			}
			catch {
				logger.error("\(error)")
			}
		}
	}
}

#Preview {
	DashboardView()
		.environment(HealthKitManager())
}
