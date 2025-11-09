import Charts
import OrderedCollections
import SwiftUI

struct WeightLineChartView: View {
	@State private var isAnimated = false
	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let context: ChartContext

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return self.context.store.weightDiscreteMetricByDate[normalizedDate]
				}
			},
		)
	}

	private var chartYScaleDomain: ClosedRange<Double> {
		let minValue = self.context.store.minimumWeight
		let maxValue = self.context.store.maximumWeight

		let range = maxValue - minValue
		let padding = range * 0.2

		let paddedMin = minValue - padding
		let paddedMax = maxValue + padding

		let niceMin = floor(paddedMin)
		let niceMax = ceil(paddedMax)

		return niceMin ... niceMax
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

			RuleMark(y: .value("Average Weight", self.context.store.averageWeight))
				.foregroundStyle(self.context.metricType.color)
				.lineStyle(.init(lineWidth: 1, dash: [5]))
				.opacity(self.isAnimated ? 1 : 0)

			ForEach(self.context.store.weightDiscreteMetricByDate.values) { discreteMetric in
				AreaMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					yStart: .value(
						"Weight",
						self.isAnimated ? discreteMetric.value : self.context.store.minimumWeight,
					),
					yEnd: .value("Minimum Weight", self.context.store.minimumWeight),
				)
				.foregroundStyle(
					Gradient(colors: [self.context.metricType.color.opacity(0.5), .clear]),
				)

				LineMark(
					x: .value("Day", discreteMetric.date, unit: .day),
					y: .value("Weight", self.isAnimated ? discreteMetric.value : self.context.store.minimumWeight),
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
		.chartYScale(domain: self.chartYScaleDomain)
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date)
		.onChange(of: self.context.store.weightDiscreteMetricByDate, initial: true) { _, newValue in
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
	@Previewable @State var metricStore = MetricStore()

	ChartCardView(context: .weightLine(store: metricStore))
		.task {
			try! await metricStore.fetchMetrics()
		}
}
