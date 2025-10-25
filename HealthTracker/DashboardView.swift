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
	@State private var rawSelectedDate: Date? = nil
	@State private var selectedStat = HealthMetricContext.steps

	var selectedHealthMetric: HealthMetric? {
		guard let rawSelectedDate = self.rawSelectedDate else {
			return nil
		}

		return self.healthKitManager.stepData.first { metric in
			Calendar.current.isDate(rawSelectedDate, inSameDayAs: metric.date)
		}
	}

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
							if let selectedHealthMetric = self.selectedHealthMetric {
								RuleMark(x: .value("Selected Metric", selectedHealthMetric.date, unit: .day))
									.foregroundStyle(.gray.opacity(0.3))
									.offset(y: -10)
									.annotation(
										position: .top,
										spacing: 0,
										overflowResolution: .init(
											x: .fit(to: .chart),
											y: .disabled,
										),
									) {
										self.annotationView(selectedHealthMetric)
									}
							}

							RuleMark(y: .value("Average", self.healthKitManager.averageStepCount))
								.foregroundStyle(.secondary)
								.lineStyle(.init(lineWidth: 1, dash: [5]))

							ForEach(self.healthKitManager.stepData) { steps in
								BarMark(
									x: .value("Date", steps.date, unit: .day),
									y: .value("Steps", steps.value),
								)
								.foregroundStyle(.pink.gradient)
								.opacity(
									self.rawSelectedDate == nil || steps.date == self.selectedHealthMetric?.date ? 1.0 : 0.3,
								)
							}
						}
						.frame(height: 150)
						.chartXSelection(value: self.$rawSelectedDate.animation(.smooth(duration: 0.25)))
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

	func annotationView(_ selectedHealthMetric: HealthMetric) -> some View {
		VStack(alignment: .leading) {
			Text(
				selectedHealthMetric.date,
				format: .dateTime.weekday(.abbreviated).month(.abbreviated).day(),
			)
			.font(.footnote.bold())
			.foregroundStyle(.secondary)

			Text(selectedHealthMetric.value, format: .number.precision(.fractionLength(0)))
				.fontWeight(.heavy)
				.foregroundStyle(.pink)
		}
		.padding(12)
		.background {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(.secondarySystemBackground))
				.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
		}
	}
}

#Preview {
	DashboardView()
		.environment(HealthKitManager())
}
