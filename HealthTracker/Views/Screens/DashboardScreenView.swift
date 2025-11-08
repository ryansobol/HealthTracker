import Charts
import OSLog
import SwiftUI

struct DashboardScreenView: View {
	private let logger = Logger(category: Self.self)

	@Environment(MetricStore.self) private var metricStore

	@State private var appError: AppError? = nil
	@State private var isHealthKitAuthorizationPresented = false
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
						StepBarCardView()

						StepPieCardView()

					case .weight:
						WeightLineCardView()

						WeightBarCardView()
					}
				}
			}
			.padding()
			.navigationTitle("Dashboard")
			.navigationDestination(for: MetricType.self) { metric in
				DiscreteMetricScreenView(
					metricType: metric,
					isHealthKitAuthorizationPresented: self.$isHealthKitAuthorizationPresented,
				)
			}
		}
		.tint(self.selectedMetricType.color)
		.fullScreenCover(isPresented: self.$isHealthKitAuthorizationPresented, onDismiss: {
			Task {
				do {
					#if targetEnvironment(simulator)
						try await self.metricStore.createFakeMetrics()
					#endif

					try await self.metricStore.fetchMetrics()
				}
				catch {
					self.logger.error("\(error)")
				}
			}
		}, content: {
			HealthKitAuthorizationScreenView()
		})
		.alert(for: self.$appError)
		.task {
			do {
				try await self.metricStore.fetchMetrics()
			}
			catch is AuthorizationRequestNecessaryError {
				self.isHealthKitAuthorizationPresented = true
			}
			catch let error as AppError {
				self.logger.error(for: error)

				self.appError = error
			}
			catch {
				let error = AppError.caught(underlyingError: error)

				self.logger.error(for: error)

				self.appError = error
			}
		}
	}
}

#Preview {
	@Previewable @State var metricStore = MetricStore()

	DashboardScreenView()
		.environment(metricStore)
}
