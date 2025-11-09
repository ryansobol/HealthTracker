import Charts
import OrderedCollections
import SwiftUI

struct StepPieChartView<Context: ChartViewContext>: View {
	@State private var isAnimated = false
	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: Context

	private var selectedValueBinding: Binding<Double?> {
		return Binding(
			get: { self.selectedAverageMetric?.value },
			set: { newValue in
				self.selectedAverageMetric = newValue.flatMap { value in
					self.context.store.averageMetricByWeekday.values
						.first(into: 0.0) { cummulativeValue, averageMetric in
							cummulativeValue += averageMetric.value

							return value <= cummulativeValue
						}
				}
			},
		)
	}

	private func isSectorMarkOpaque(for averageMetric: AverageMetric) -> Bool {
		guard let selectedAverageMetric = self.selectedAverageMetric else {
			return false
		}

		return selectedAverageMetric.weekday != averageMetric.weekday
	}

	private func opacitySectorMark(for averageMetric: AverageMetric) -> Double {
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
			ForEach(self.context.store.averageMetricByWeekday.values) { averageMetric in
				SectorMark(
					angle: .value("Average Steps", self.isAnimated ? averageMetric.value : 0),
					innerRadius: .ratio(0.618),
					outerRadius: self.selectedAverageMetric?.weekday == averageMetric.weekday ? 140 : 110,
					angularInset: 1,
				)
				.foregroundStyle(self.context.metricType.color.gradient)
				.cornerRadius(6)
				.opacity(self.opacitySectorMark(for: averageMetric))
			}
		}
		.chartAngleSelection(value: self.selectedValueBinding)
		.chartBackground { _ in
			self.chartAverage(
				title: self.selectedAverageMetric?.weekday.symbol ?? "Daily",
				value: self.selectedAverageMetric?.value ?? self.context.store.discreteMetricAverage,
			)
		}
		.animation(.smooth(duration: 0.1), value: self.selectedAverageMetric?.weekday)
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

	ChartCardView(context: StepPieViewContext(store: stepStore))
		.task {
			try! await stepStore.fetchMetrics()
		}
}
