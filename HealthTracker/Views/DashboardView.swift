import Charts
import OSLog
import SwiftUI

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "DashboardView")

enum HealthMetricContext: CaseIterable, Identifiable {
	case steps
	case weight

	var id: Self {
		return self
	}

	var title: String {
		return switch self {
		case .steps: "Steps"
		case .weight: "Weight"
		}
	}

	var tint: Color {
		return switch self {
		case .steps: .pink
		case .weight: .indigo
		}
	}
}

struct DashboardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var isShowingPermissionPrimingSheet = false
	@State private var selectedStat = HealthMetricContext.steps

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					Picker("Selected Stat", selection: self.$selectedStat) {
						ForEach(HealthMetricContext.allCases) { metric in
							Text(metric.title)
						}
					}
					.pickerStyle(.segmented)

					StepBarChart(selectedStat: self.selectedStat)

					StepPieChart()
				}
			}
			.padding()
			.navigationTitle("Dashboard")
			.navigationDestination(for: HealthMetricContext.self) { metric in
				HealthDataListView(metric: metric)
			}
		}
		.tint(self.selectedStat.tint)
		.fullScreenCover(isPresented: self.$isShowingPermissionPrimingSheet, onDismiss: {
			Task {
				do {
					try await self.healthKitManager.addFakeDataToSimulatorData()
					try await self.healthKitManager.fetchData()
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
				self.isShowingPermissionPrimingSheet =
					try await self.healthKitManager.shouldRequestAuthorization
			}
			catch {
				logger.error("\(error)")
			}
		}
		.task {
			do {
				try await self.healthKitManager.fetchData()
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
