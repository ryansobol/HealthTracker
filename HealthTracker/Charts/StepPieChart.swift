import Charts
import SwiftUI

struct StepPieChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var rawSelectedAverageMetricValue: Double? = 0

	var selectedAverageMetric: AverageMetric? {
		guard let rawSelectedAverageMetricValue = self.rawSelectedAverageMetricValue else {
			return nil
		}

		var total = 0.0

		return self.healthKitManager.stepAverageMetrics.first { stepAverageMetric in
			total += stepAverageMetric.value

			return rawSelectedAverageMetricValue <= total
		}
	}

	var body: some View {
		VStack(alignment: .leading) {
			VStack(alignment: .leading) {
				Label("Averages", systemImage: "calendar")
					.font(.title3.bold())
					.foregroundStyle(.pink)

				Text("Last 28 Days")
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Chart {
				ForEach(self.healthKitManager.stepAverageMetrics) { averageMetric in
					SectorMark(
						angle: .value("Average Steps", averageMetric.value),
						innerRadius: .ratio(0.618),
						outerRadius: self.selectedAverageMetric?.weekday == averageMetric.weekday ? 140 : 110,
						angularInset: 1,
					)
					.foregroundStyle(.pink.gradient)
					.cornerRadius(6)
					.opacity(self.selectedAverageMetric?.weekday == averageMetric.weekday ? 1 : 0.3)
				}
			}
			.frame(height: 240)
			.chartAngleSelection(
				value: self.$rawSelectedAverageMetricValue.animation(.smooth(duration: 0.25)),
			)
			.chartBackground { _ in
				if let selectedStepChartMetric = self.selectedAverageMetric {
					VStack {
						Text(selectedStepChartMetric.weekday.symbol)
							.font(.title2.bold())
							.animation(.none, value: selectedStepChartMetric.weekday)

						Text(selectedStepChartMetric.value, format: .number.precision(.fractionLength(0)))
							.fontWeight(.medium)
							.foregroundStyle(.secondary)
							.contentTransition(.numericText())
					}
				}
			}
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	StepPieChart()
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
