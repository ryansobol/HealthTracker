import Charts
import OrderedCollections
import SwiftUI

struct WeightBarChartView<Context: ChartViewContext>: View {
	@State private var isAnimated = false
	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: Context

	private var selectedWeekdayBinding: Binding<Weekday?> {
		return Binding(
			get: { self.selectedAverageMetric?.weekday },
			set: { newValue in
				self.selectedAverageMetric = newValue.flatMap { weekday in
					return self.context.store.averageMetricByWeekday[weekday]
				}
			},
		)
	}

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

	private var chartYScaleDomain: ClosedRange<Double> {
		let minValue = self.context.store.averageMetricMinimum
		let maxValue = self.context.store.averageMetricMaximum

		let range = maxValue - minValue
		let padding = range * 0.5

		let paddedMin = minValue - padding
		let paddedMax = maxValue + padding

		let niceMin = floor(paddedMin)
		let niceMax = ceil(paddedMax)

		return niceMin ... niceMax
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

			ForEach(self.context.store.averageMetricByWeekday.values) { averageDiffMetric in
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
		.chartXSelection(value: self.selectedWeekdayBinding)
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
		.chartYScale(domain: self.chartYScaleDomain)
		.animation(.smooth(duration: 0.05), value: self.selectedAverageMetric?.weekday)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedAverageMetric?.weekday)
		.onChange(of: self.context.store.averageMetricByWeekday, initial: true) { _, newValue in
			guard !self.isAnimated else {
				return
			}

			if newValue.isEmpty {
				return
			}

			self.isAnimated = true
		}
	}
}

#Preview {
	@Previewable @State var weightStore = WeightStore()

	ChartCardView(context: WeightBarViewContext(store: weightStore))
		.task {
			try! await weightStore.fetchMetrics()
		}
}
