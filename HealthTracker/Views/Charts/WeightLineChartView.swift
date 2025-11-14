import Charts
import OrderedCollections
import SwiftUI

struct WeightLineChartView<Context: ChartViewContextual>: View {
	@State private var isAnimated = false
	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let context: Context

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return self.context.metricStore.discreteMetricByDate[normalizedDate]
				}
			},
		)
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
							format: .number.precision(.fractionLength(1)),
						)
						.foregroundStyle(self.context.metricType.color),
					)
			}

			let title = self.context.metricType.title

			RuleMark(y: .value("Average \(title)", self.context.metricStore.discreteMetricAverage))
				.foregroundStyle(self.context.metricType.color)
				.lineStyle(.init(lineWidth: 1, dash: [5]))
				.opacity(self.isAnimated ? 1 : 0)

			ForEach(self.context.metricStore.discreteMetricByDate.values) { discreteMetric in
				AreaMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					yStart: .value(
						title,
						self.isAnimated ? discreteMetric.value : self.context.chartYScale.lowerBound,
					),
					yEnd: .value("Minimum \(title)", self.context.chartYScale.lowerBound),
				)
				.foregroundStyle(
					Gradient(colors: [self.context.metricType.color.opacity(0.5), .clear]),
				)

				LineMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					y: .value(
						title,
						self.isAnimated ? discreteMetric.value : self.context.metricStore.discreteMetricMinimum,
					),
				)
				.foregroundStyle(self.context.metricType.color)
				.symbol(.circle)
			}
			.interpolationMethod(.catmullRom)
		}
		.chartXSelection(value: self.selectedDateBinding)
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
		.chartYScale(domain: self.context.chartYScale)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date)
		.setTrue(self.$isAnimated, when: !self.context.metricStore.averageMetricByWeekday.isEmpty)
	}
}

#Preview {
	@Previewable @State var weightStore = WeightStore()

	ChartCardView(context: WeightLineViewContext(metricStore: weightStore))
		.task {
			try! await weightStore.fetchMetrics()
		}
}
