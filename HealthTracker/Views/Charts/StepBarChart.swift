import Charts
import OrderedCollections
import SwiftUI

struct StepBarChart: View {
	@Environment(MetricStore.self) private var metricStore

	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let chartType: ChartType

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
				RuleMark(x: .value("Selected Day", selectedDiscreteMetric.date, unit: .day))
					.selection(
						label: Text(
							selectedDiscreteMetric.date,
							format: .dateTime.weekday(.abbreviated).month(.abbreviated).day(),
						),
						value: Text(
							selectedDiscreteMetric.value,
							format: .number.precision(.fractionLength(0)),
						)
						.foregroundStyle(self.chartType.metricType.color),
					)
			}

			RuleMark(y: .value("Average Steps", self.metricStore.averageSteps))
				.foregroundStyle(.secondary)
				.lineStyle(.init(lineWidth: 1, dash: [5]))

			ForEach(self.metricStore.stepDiscreteMetricByDate.values) { discreteMetric in
				BarMark(
					x: .value("Date", discreteMetric.date, unit: .day),
					y: .value("Steps", discreteMetric.value),
				)
				.foregroundStyle(self.chartType.metricType.color.gradient)
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
}

#Preview {
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}
