import Charts
import OSLog
import SwiftUI

struct DashboardView: View {
	private let logger = Logger(category: Self.self)

	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var appError: AppError? = nil
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
					self.logger.error("\(error)")
				}
			}
		}, content: {
			HealthKitPermissionPrimingView()
		})
		.alert(throwable: self.$appError)
		.task {
			do {
				try await self.healthKitManager.fetchMetrics()
			}
			catch is AuthorizationRequestNecessaryError {
				self.isPermissionPrimerPresented = true
			}
			catch let error as AppError {
				logger.error(error)

				self.appError = error
			}
			catch {
				let error = AppError.caught(underlyingError: error)

				self.logger.error(error)

				self.appError = error
			}
		}
	}
}

#Preview {
	DashboardView()
		.environment(HealthKitManager())
}
