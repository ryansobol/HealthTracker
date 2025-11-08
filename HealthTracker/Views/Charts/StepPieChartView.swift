import Charts
import OrderedCollections
import SwiftUI

struct StepPieChartView: View {
	@Environment(MetricStore.self) private var metricStore

	@State private var selectedAverageMetric: AverageMetric? = nil

	let context: ChartContext

	private var selectedValueBinding: Binding<Double?> {
		return Binding(
			get: { self.selectedAverageMetric?.value },
			set: { newValue in
				self.selectedAverageMetric = newValue.flatMap { value in
					self.metricStore.stepAverageMetricByWeekday.values
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

	var body: some View {
		Chart {
			ForEach(self.metricStore.stepAverageMetricByWeekday.values) { averageMetric in
				SectorMark(
					angle: .value("Average Steps", averageMetric.value),
					innerRadius: .ratio(0.618),
					outerRadius: self.selectedAverageMetric?.weekday == averageMetric.weekday ? 140 : 110,
					angularInset: 1,
				)
				.foregroundStyle(self.context.metricType.color.gradient)
				.cornerRadius(6)
				.opacity(self.isSectorMarkOpaque(for: averageMetric) ? 0.3 : 1)
			}
		}
		.chartAngleSelection(value: self.selectedValueBinding)
		.chartBackground { _ in
			self.chartAverage(
				title: self.selectedAverageMetric?.weekday.symbol ?? "Daily",
				value: self.selectedAverageMetric?.value ?? self.metricStore.averageSteps,
			)
		}
		.animation(.smooth(duration: 0.1), value: self.selectedAverageMetric?.weekday)
		.sensoryFeedback(.selection, trigger: self.selectedAverageMetric?.weekday)
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
	@Previewable @State var metricStore = MetricStore()

	ChartCardView(context: .stepPie(store: metricStore))
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}
