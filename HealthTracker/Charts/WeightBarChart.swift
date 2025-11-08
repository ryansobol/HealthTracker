import Charts
import OrderedCollections
import SwiftUI

struct WeightBarChart: View {
	@Environment(MetricStore.self) private var metricStore

	@State private var selectedAverageMetric: AverageMetric? = nil

	let chartType: ChartType

	private var selectedWeekdayBinding: Binding<Weekday?> {
		return Binding(
			get: { self.selectedAverageMetric?.weekday },
			set: { newValue in
				self.selectedAverageMetric = newValue.flatMap { weekday in
					return self.metricStore.weightDiffAverageMetricByWeekday[weekday]
				}
			},
		)
	}

	private func isBarMarkOpaque(for averageMetric: AverageMetric) -> Bool {
		guard let selectedAverageMetric = self.selectedAverageMetric else {
			return false
		}

		return selectedAverageMetric.weekday != averageMetric.weekday
	}

	var body: some View {
		Chart {
			if let selectedAverageMetric = self.selectedAverageMetric {
				RuleMark(x: .value("Selected Average Metric", selectedAverageMetric.weekday))
					.selection(
						label: Text(selectedAverageMetric.weekday.symbol),
						value: Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
							.foregroundStyle(
								selectedAverageMetric.value >= 0
									? self.chartType.metricType.tint
									: Color.mint,
							),
					)
			}

			ForEach(self.metricStore.weightDiffAverageMetricByWeekday.values) { averageDiffMetric in
				BarMark(
					x: .value("Weekday", averageDiffMetric.weekday),
					y: .value("Average Differece", averageDiffMetric.value),
				)
				.foregroundStyle(
					averageDiffMetric.value >= 0
						? self.chartType.metricType.tint.gradient
						: Color.mint.gradient,
				)
				.opacity(self.isBarMarkOpaque(for: averageDiffMetric) ? 0.3 : 1.0)
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
		.animation(.smooth(duration: 0.05), value: self.selectedAverageMetric?.weekday)
		.sensoryFeedback(.selection, trigger: self.selectedAverageMetric?.weekday)
	}
}

#Preview {
	@Previewable @State var metricStore = MetricStore()

	WeightBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}
