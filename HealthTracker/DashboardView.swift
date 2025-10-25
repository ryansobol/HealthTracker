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

					VStack {
						NavigationLink(value: self.selectedStat) {
							HStack {
								VStack(alignment: .leading) {
									Label("Steps", systemImage: "figure.walk")
										.font(.title3.bold())
										.foregroundStyle(.pink)

									Text("Avg: \(Int(self.healthKitManager.averageStepCount)) steps")
										.font(.caption)
								}

								Spacer()

								Image(systemName: "chevron.right")
							}
						}
						.foregroundStyle(.secondary)
						.padding(.bottom, 12)

						Chart {
							RuleMark(y: .value("Average", self.healthKitManager.averageStepCount))
								.foregroundStyle(.secondary)
								.lineStyle(.init(lineWidth: 1, dash: [5]))

							ForEach(self.healthKitManager.stepData) { steps in
								BarMark(
									x: .value("Date", steps.data, unit: .day),
									y: .value("Steps", steps.value),
								)
								.foregroundStyle(.pink.gradient)
							}
						}
						.frame(height: 150)
						.chartXAxis {
							AxisMarks { _ in
								AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
							}
						}
						.chartYAxis {
							AxisMarks { value in
								AxisGridLine()
									.foregroundStyle(.gray.opacity(0.3))

								AxisValueLabel(
									(value.as(Double.self) ?? 0)
										.formatted(.number.notation(.compactName)),
								)
							}
						}
					}
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color(.secondarySystemBackground))
					}

					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							Label("Averages", systemImage: "calendar")
								.font(.title3.bold())
								.foregroundStyle(.pink)

							Text("Last 28 Days")
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						RoundedRectangle(cornerRadius: 12)
							.foregroundStyle(.secondary)
							.frame(height: 240)
					}
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color(.secondarySystemBackground))
					}
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
