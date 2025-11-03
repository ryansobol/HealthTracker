import Charts
import SwiftUI

struct WeightBarChart: View {
	let metricType = MetricType.weight

	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var selectedAverageMetric: AverageMetric? = nil

	private var selectedWeekdayBinding: Binding<Weekday?> {
		return Binding(
			get: { self.selectedAverageMetric?.weekday },
			set: { newValue in
				self.selectedAverageMetric = if let newValue {
					self.healthKitManager.weightAverageDiffMetrics.first { averageDiffMetric in
						averageDiffMetric.weekday == newValue
					}
				}
				else {
					nil
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
					.foregroundStyle(.gray.opacity(0.3))
					.offset(y: -10)
					.annotation(
						position: .top,
						spacing: 0,
						overflowResolution: .init(
							x: .fit(to: .chart),
							y: .disabled,
						),
					) {
						self.annotationView(selectedAverageMetric)
					}
			}

			ForEach(self.healthKitManager.weightAverageDiffMetrics) { averageDiffMetric in
				BarMark(
					x: .value("Weekday", averageDiffMetric.weekday),
					y: .value("Average Differece", averageDiffMetric.value),
				)
				.foregroundStyle(
					averageDiffMetric.value >= 0
						? self.metricType.tint.gradient
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

	func annotationView(_ selectedAverageMetric: AverageMetric) -> some View {
		VStack(alignment: .leading) {
			Text(selectedAverageMetric.weekday.symbol)
				.font(.footnote.bold())
				.foregroundStyle(.secondary)

			Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
				.fontWeight(.heavy)
				.foregroundStyle(selectedAverageMetric.value >= 0 ? self.metricType.tint : Color.mint)
		}
		.padding(12)
		.background {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(.secondarySystemBackground))
				.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
		}
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightBarCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}
