import Charts
import OrderedCollections
import SwiftUI

struct StepBarChartView<Context: ChartViewContextual>: View {
	@State private var isAnimated = false
	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let context: Context

	var body: some View {
		Chart {
			if let selectedDiscreteMetric = self.selectedDiscreteMetric {
				RuleMark(x: .value("Selected Day", selectedDiscreteMetric.date, unit: .day))
					.selection(
						label: Text(
							selectedDiscreteMetric.date,
							format: .monthDayAbbrievated,
						),
						value: Text(selectedDiscreteMetric.value, format: .step)
							.foregroundStyle(self.context.metricType.color),
					)
			}

			let title = self.context.metricType.title

			RuleMark(y: .value("Average \(title)", self.context.metricStore.discreteMetricAverage))
				.foregroundStyle(self.context.metricType.color)
				.lineStyle(.init(lineWidth: 1, dash: [5]))
				.opacity(self.isAnimated ? 1 : 0)
				.accessibilityHidden(true)

			ForEach(self.context.metricStore.discreteMetricByDate.values) { discreteMetric in
				Plot {
					BarMark(
						x: .value("Date", discreteMetric.date, unit: .day),
						y: .value(title, self.isAnimated ? discreteMetric.value : 0),
					)
					.foregroundStyle(self.context.metricType.color.gradient)
					.opacity(
						.when(
							discreteMetric,
							selected: self.selectedDiscreteMetric,
							isAnimated: self.isAnimated,
						),
					)
				}
				.accessibilityLabel(discreteMetric.date.formatted(.monthDay))
				.accessibilityValue(discreteMetric.accessibleValue(for: self.context.metricType))
			}
		}
		.chartXSelection(
			value: .selectingDate(from: self.$selectedDiscreteMetric, in: self.context.metricStore),
		)
		.chartXAxis {
			self.context.chartXAxisContent
		}
		.chartYAxis {
			self.context.chartYAxisContent
		}
		.chartYScale(domain: self.context.chartYScale)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date.weekday)
		.setTrue(self.$isAnimated, when: !self.context.metricStore.averageMetricByWeekday.isEmpty)
	}
}

#Preview {
	@Previewable @State var stepStore = StepStore()

	ChartCardView(context: StepBarViewContext(metricStore: stepStore))
		.task {
			try! await stepStore.fetchMetrics()
		}
}
