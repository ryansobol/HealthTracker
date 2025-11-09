import Charts
import OSLog
import SwiftUI

struct DashboardScreenView: View {
	private let logger = Logger(category: Self.self)

	@Environment(StepStore.self) private var stepStore
	@Environment(WeightStore.self) private var weightStore

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
						ChartCardView(context: StepBarViewContext(store: self.stepStore))

						ChartCardView(context: StepPieViewContext(store: self.stepStore))

					case .weight:
						ChartCardView(context: WeightLineViewContext(store: self.weightStore))

						ChartCardView(context: WeightBarViewContext(store: self.weightStore))
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
						try await self.createFakeMetrics()
					#endif

					try await self.fetchMetrics()
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
				try await self.fetchMetrics()
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

	private func createFakeMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.stepStore.createFakeMetrics() }
			group.addTask { try await self.weightStore.createFakeMetrics() }

			try await group.waitForAll()
		}
	}

	private func fetchMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.stepStore.fetchMetrics() }
			group.addTask { try await self.weightStore.fetchMetrics() }

			try await group.waitForAll()
		}
	}
}

#Preview {
	@Previewable @State var stepStore = StepStore()
	@Previewable @State var weightStore = WeightStore()

	DashboardScreenView()
		.environment(stepStore)
		.environment(weightStore)
}
