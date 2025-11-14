import Charts
import OrderedCollections
import SwiftUI

struct WeightBarChartView<Context: ChartViewContextual>: View {
	@State private var isAnimated = false
	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: Context

	private func opacityBarkMark(for averageMetric: AverageMetric) -> Double {
		guard self.isAnimated else {
			return 0.0
		}

		guard let selectedAverageMetric = self.selectedAverageMetric else {
			return 1.0
		}

		if selectedAverageMetric.weekday == averageMetric.weekday {
			return 1.0
		}

		return 0.3
	}

	var body: some View {
		Chart {
			if let selectedAverageMetric = self.selectedAverageMetric {
				RuleMark(x: .value("Selected Weekday", selectedAverageMetric.weekday))
					.selection(
						label: Text(selectedAverageMetric.weekday.symbol),
						value: Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
							.foregroundStyle(
								selectedAverageMetric.value >= 0
									? self.context.metricType.color
									: Color.mint,
							),
					)
			}

			let title = self.context.metricType.title

			ForEach(self.context.metricStore.averageMetricByWeekday.values) { averageDiffMetric in
				BarMark(
					x: .value("Weekday", averageDiffMetric.weekday),
					y: .value("Average \(title) Differece", self.isAnimated ? averageDiffMetric.value : 0),
				)
				.foregroundStyle(
					averageDiffMetric.value >= 0
						? self.context.metricType.color.gradient
						: Color.mint.gradient,
				)
				.opacity(self.opacityBarkMark(for: averageDiffMetric))
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
			AxisMarks { value in
				AxisGridLine()
					.foregroundStyle(.gray.opacity(0.3))

				AxisValueLabel(
					(value.as(Double.self) ?? 0)
						.formatted(.number.notation(.compactName)),
				)
			}
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
