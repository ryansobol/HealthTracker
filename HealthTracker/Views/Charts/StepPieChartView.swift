import Charts
import OrderedCollections
import SwiftUI

struct StepPieChartView<Context: ChartViewContextual>: View {
	@State private var isAnimated = false
	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: Context

	var body: some View {
		Chart {
			let title = self.context.metricType.title

			ForEach(self.context.metricStore.averageMetricByWeekday.values) { averageMetric in
				SectorMark(
					angle: .value("Average \(title)", self.isAnimated ? averageMetric.value : 0),
					innerRadius: .ratio(0.618),
					outerRadius: self.selectedAverageMetric?.weekday == averageMetric.weekday ? 140 : 110,
					angularInset: 1,
				)
				.foregroundStyle(self.context.metricType.color.gradient)
				.cornerRadius(6)
				.opacity(
					.when(
						averageMetric,
						selected: self.selectedAverageMetric,
						isAnimated: self.isAnimated,
					),
				)
			}
		}
		.chartAngleSelection(
			value: .selectingCumulativeValue(
				from: self.$selectedAverageMetric,
				in: self.context.metricStore,
			),
		)
		.chartBackground { _ in
			self.chartAverage(
				title: self.selectedAverageMetric?.weekday.symbol ?? "Daily",
				value: self.selectedAverageMetric?.value ?? self.context.metricStore.discreteMetricAverage,
			)
		}
		.animation(.smooth(duration: 0.1), value: self.selectedAverageMetric?.weekday)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedAverageMetric?.weekday)
		.setTrue(self.$isAnimated, when: !self.context.metricStore.averageMetricByWeekday.isEmpty)
	}

	private func chartAverage(title: String, value: Double) -> some View {
		VStack {
			Text(title)
				.font(.title2.bold())
				.animation(.none, value: title)

			Text(value, format: .number.precision(.fractionLength(0)))
				.fontWeight(.medium)
				.foregroundStyle(.secondary)
				.contentTransition(.numericText())
		}
	}
}

#Preview {
	@Previewable @State var stepStore = StepStore()

	ChartCardView(context: StepPieViewContext(metricStore: stepStore))
		.task {
			try! await stepStore.fetchMetrics()
		}
}
