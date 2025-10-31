import Charts
import SwiftUI

struct StepBarChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var rawSelectedDate: Date? = nil

	let selectedStat: HealthMetricContext

	var selectedHealthMetric: HealthMetric? {
		guard let rawSelectedDate = self.rawSelectedDate else {
			return nil
		}

		return self.healthKitManager.stepData.first { metric in
			Calendar.current.isDate(rawSelectedDate, inSameDayAs: metric.date)
		}
	}

	var body: some View {
		VStack {
			NavigationLink(value: self.selectedStat) {
				HStack {
					VStack(alignment: .leading) {
						Label("Steps", systemImage: "figure.walk")
							.font(.title3.bold())
							.foregroundStyle(self.selectedStat.tint)

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
					.foregroundStyle(self.selectedStat.tint.gradient)
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
				.foregroundStyle(self.selectedStat.tint)
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
	@Previewable @State var healthKitManager = HealthKitManager()

	StepBarChart(selectedStat: .steps)
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
