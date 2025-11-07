import Charts
import OrderedCollections
import SwiftUI

struct StepBarChart: View {
	let metricType = MetricType.steps

	@Environment(MetricStore.self) private var metricStore

	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return self.metricStore.stepDiscreteMetricByDate[normalizedDate]
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

			RuleMark(y: .value("Average", self.metricStore.averageStepCount))
				.foregroundStyle(.secondary)
				.lineStyle(.init(lineWidth: 1, dash: [5]))

			ForEach(self.metricStore.stepDiscreteMetricByDate.values) { discreteMetric in
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
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}
