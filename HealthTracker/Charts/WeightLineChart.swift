import Charts
import OrderedCollections
import SwiftUI

struct WeightLineChart: View {
	let goal = 165
	@Environment(MetricStore.self) private var metricStore

	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let chartType: ChartType

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return self.metricStore.weightDiscreteMetricByDate[normalizedDate]
				}
			},
		)
	}

	var minValue: Double {
		return self.metricStore.weightDiscreteMetricByDate.values.map { $0.value }.min() ?? 0
	}

	var body: some View {
		Chart {
			if let selectedDiscreteMetric = self.selectedDiscreteMetric {
				RuleMark(x: .value("Selected Metric", selectedDiscreteMetric.date, unit: .day))
					.selection(
						label: Text(
							selectedDiscreteMetric.date,
							format: .dateTime.weekday(.abbreviated).month(.abbreviated).day(),
						),
						value: Text(
							selectedDiscreteMetric.value,
							format: .number.precision(.fractionLength(1)),
						)
						.foregroundStyle(self.chartType.metricType.tint),
					)
			}

			RuleMark(y: .value("Goal", self.goal))
				.foregroundStyle(.mint)
				.lineStyle(.init(lineWidth: 1, dash: [5]))

			ForEach(self.metricStore.weightDiscreteMetricByDate.values) { discreteMetric in
				AreaMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					yStart: .value("Value", discreteMetric.value),
					yEnd: .value("Min value", self.minValue),
				)
				.foregroundStyle(
					Gradient(colors: [self.chartType.metricType.tint.opacity(0.5), .clear]),
				)

				LineMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					y: .value("Value", discreteMetric.value),
				)
				.foregroundStyle(self.chartType.metricType.tint)
				.symbol(.circle)
			}
			.interpolationMethod(.catmullRom)
		}
		.chartXSelection(value: self.selectedDateBinding)
		.chartYScale(domain: .automatic(includesZero: false))
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
			}
		}
		.chartYAxis {
			AxisMarks { _ in
				AxisGridLine()
					.foregroundStyle(.gray.opacity(0.3))

				AxisValueLabel()
			}
		}
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date)
	}
}

#Preview {
	@Previewable @State var metricStore = MetricStore()

	WeightLineCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}
