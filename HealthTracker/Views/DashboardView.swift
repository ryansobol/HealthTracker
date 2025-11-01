import Charts
import OSLog
import SwiftUI

private let logger = Logger.dashboardView

struct DashboardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var isPermissionPrimerPresented = false
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
				DiscreteMetricListView(
					metricType: metric,
					isPermissionPrimerPresented: self.$isPermissionPrimerPresented,
				)
			}
		}
		.tint(self.selectedMetricType.tint)
		.fullScreenCover(isPresented: self.$isPermissionPrimerPresented, onDismiss: {
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
				self.isPermissionPrimerPresented = true
			}
			catch let AuthorizationError.sharingNotAuthorized(mediaType) {
				logger.error("Sharing not authorized for \(mediaType)")
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
