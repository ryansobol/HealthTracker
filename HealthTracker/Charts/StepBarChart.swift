import Charts
import SwiftUI

struct StepBarChart: View {
	let metricType = MetricType.steps

	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = if let newValue {
					self.healthKitManager.stepDiscreteMetrics.first { discreteMetric in
						Calendar.current.isDate(newValue, inSameDayAs: discreteMetric.date)
					}
				}
				else {
					nil
				}
			},
		)
	}

	private func isBarMarkOpaque(for discreteMetric: DiscreteMetric) -> Bool {
		guard let selectedDiscreteMetric = self.selectedDiscreteMetric else {
			return false
		}

		return selectedDiscreteMetric.date != discreteMetric.date
	}

	var body: some View {
		Chart {
			if let selectedDiscreteMetric = self.selectedDiscreteMetric {
				RuleMark(x: .value("Selected Metric", selectedDiscreteMetric.date, unit: .day))
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
						self.annotationView(selectedDiscreteMetric)
					}
			}

			RuleMark(y: .value("Average", self.healthKitManager.averageStepCount))
				.foregroundStyle(.secondary)
				.lineStyle(.init(lineWidth: 1, dash: [5]))

			ForEach(self.healthKitManager.stepDiscreteMetrics) { discreteMetric in
				BarMark(
					x: .value("Date", discreteMetric.date, unit: .day),
					y: .value("Steps", discreteMetric.value),
				)
				.foregroundStyle(self.metricType.tint.gradient)
				.opacity(self.isBarMarkOpaque(for: discreteMetric) ? 0.3 : 1.0)
			}
		}
		.chartXSelection(value: self.selectedDateBinding)
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
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date.weekday)
	}

	func annotationView(_ selectedDiscreteMetric: DiscreteMetric) -> some View {
		VStack(alignment: .leading) {
			Text(
				selectedDiscreteMetric.date,
				format: .dateTime.weekday(.abbreviated).month(.abbreviated).day(),
			)
			.font(.footnote.bold())
			.foregroundStyle(.secondary)

			Text(selectedDiscreteMetric.value, format: .number.precision(.fractionLength(0)))
				.fontWeight(.heavy)
				.foregroundStyle(self.metricType.tint)
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

	StepBarCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}
