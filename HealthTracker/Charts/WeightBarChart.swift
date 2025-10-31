import Charts
import SwiftUI

struct WeightBarChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var rawSelectedAverageMetricWeekday: Weekday? = nil

	let selectedStat: HealthMetricContext

	var selectedAverageMetric: AverageMetric? {
		guard let rawSelectedAverageMetricWeekday = self.rawSelectedAverageMetricWeekday else {
			return nil
		}

		return self.healthKitManager.weightAverageDiffMetrics.first { averageDiffMetric in
			rawSelectedAverageMetricWeekday == averageDiffMetric.weekday
		}
	}

	var body: some View {
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Label("Average Change", systemImage: "figure")
						.font(.title3.bold())
						.foregroundStyle(self.selectedStat.tint)

					Text("Last 28 Days")
						.font(.caption)
				}

				Spacer()
			}
			.foregroundStyle(.secondary)
			.padding(.bottom, 12)

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
							? self.selectedStat.tint.gradient
							: Color.mint.gradient,
					)
					.opacity(
						self.rawSelectedAverageMetricWeekday == nil || self
							.rawSelectedAverageMetricWeekday == averageDiffMetric.weekday ? 1.0 : 0.3,
					)
				}
			}
			.frame(height: 150)
			.chartXSelection(value: self.$rawSelectedAverageMetricWeekday.animation(.smooth(duration: 0.25)))
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
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}

	func annotationView(_ selectedAverageMetric: AverageMetric) -> some View {
		VStack(alignment: .leading) {
			Text(selectedAverageMetric.weekday.symbol)
				.font(.footnote.bold())
				.foregroundStyle(.secondary)

			Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
				.fontWeight(.heavy)
				.foregroundStyle(selectedAverageMetric.value >= 0 ? self.selectedStat.tint : Color.mint)
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

	WeightBarChart(selectedStat: .weight)
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
