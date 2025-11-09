import Charts
import OrderedCollections
import SwiftUI

struct StepBarChartView<Context: ChartViewContext>: View {
	@State private var isAnimated = false
	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	let context: Context

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return self.context.store.discreteMetricByDate[normalizedDate]
				}
			},
		)
	}

	private func opacityBarMark(for discreteMetric: DiscreteMetric) -> Double {
		guard self.isAnimated else {
			return 0.0
		}

		guard let selectedDiscreteMetric = self.selectedDiscreteMetric else {
			return 1.0
		}

		if selectedDiscreteMetric.date == discreteMetric.date {
			return 1.0
		}

		return 0.3
	}

	private var chartYScaleDomain: ClosedRange<Double> {
		let minValue = 0.0
		let maxValue = self.context.store.maximum

		let range = maxValue - minValue
		let padding = range * 0.01

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
							format: .number.precision(.fractionLength(0)),
						)
						.foregroundStyle(self.context.metricType.color),
					)
			}

			RuleMark(y: .value("Average Steps", self.context.store.average))
				.foregroundStyle(self.context.metricType.color)
				.lineStyle(.init(lineWidth: 1, dash: [5]))
				.opacity(self.isAnimated ? 1 : 0)

			ForEach(self.context.store.discreteMetricByDate.values) { discreteMetric in
				BarMark(
					x: .value("Date", discreteMetric.date, unit: .day),
					y: .value("Steps", self.isAnimated ? discreteMetric.value : 0),
				)
				.foregroundStyle(self.context.metricType.color.gradient)
				.opacity(self.opacityBarMark(for: discreteMetric))
			}
		}
		.chartXSelection(value: self.selectedDateBinding)
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
			}
		}
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
		.animation(.smooth(duration: 0.25), value: self.isAnimated)
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date.weekday)
		.onChange(of: self.context.store.discreteMetricByDate, initial: true) { _, newValue in
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
	@Previewable @State var stepStore = StepStore()

	ChartCardView(context: StepBarViewContext(store: stepStore))
		.task {
			try! await stepStore.fetchMetrics()
		}
}
