import Charts
import OrderedCollections
import SwiftUI

struct WeightBarChartView<Context: ChartViewContextual>: View {
	@State private var isAnimated = false
	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: Context

	var body: some View {
		Chart {
			if let selectedAverageMetric = self.selectedAverageMetric {
				RuleMark(x: .value("Selected Weekday", selectedAverageMetric.weekday))
					.selection(
						label: Text(selectedAverageMetric.weekday.symbol),
						value: Text(selectedAverageMetric.value, format: .weightChange)
							.foregroundStyle(
								selectedAverageMetric.value >= 0
									? self.context.metricType.color
									: Color.mint,
							),
					)
			}

			let title = self.context.metricType.title

			ForEach(self.context.metricStore.averageMetricByWeekday.values) { averageMetric in
				Plot {
					BarMark(
						x: .value("Weekday", averageMetric.weekday),
						y: .value("Average \(title) Differece", self.isAnimated ? averageMetric.value : 0),
					)
					.foregroundStyle(
						averageMetric.value >= 0
							? self.context.metricType.color.gradient
							: Color.mint.gradient,
					)
					.opacity(
						.when(
							averageMetric,
							selected: self.selectedAverageMetric,
							isAnimated: self.isAnimated,
						),
					)
				}
				.accessibilityLabel(averageMetric.weekday.symbol)
				.accessibilityValue(averageMetric.accessibleValue(for: self.context.metricType))
			}
		}
		.chartXSelection(
			value: .selectingWeekday(from: self.$selectedAverageMetric, in: self.context.metricStore),
		)
		.chartXAxis {
			AxisMarks { value in
				if let weekday = value.as(Weekday.self) {
					AxisValueLabel {
						Text(weekday.shortSymbol)
					}
				}
			}
		}
		.chartXScale(domain: Weekday.allCases.map { $0.symbol }, type: .category)
		.chartYAxis {
			self.context.chartYAxisContent
		}
		.chartYScale(domain: self.context.chartYScale)
		.animation(.smooth(duration: 0.05), value: self.selectedAverageMetric?.weekday)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedAverageMetric?.weekday)
		.setTrue(self.$isAnimated, when: !self.context.metricStore.averageMetricByWeekday.isEmpty)
	}
}

#Preview {
	@Previewable @State var weightStore = WeightStore()

	ChartCardView(context: WeightBarViewContext(metricStore: weightStore))
		.task {
			try! await weightStore.fetchMetrics()
		}
}
