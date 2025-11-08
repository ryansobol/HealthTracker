import OrderedCollections
import SwiftUI

struct WeightBarCardView: View {
	let chartType = ChartType.weightBar

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.metricStore.weightDiffAverageMetricByWeekday.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.bar",
						description: "No weight data collected from HealthKit",
					)
				}
				else {
					WeightBarChart(chartType: self.chartType)
				}
			}
			.frame(height: 150)
		}
	}

	func annotationView(_ selectedAverageMetric: AverageMetric) -> some View {
		VStack(alignment: .leading) {
			Text(selectedAverageMetric.weekday.symbol)
				.font(.footnote.bold())
				.foregroundStyle(.secondary)

			Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
				.fontWeight(.heavy)
				.foregroundStyle(
					selectedAverageMetric.value >= 0
						? self.chartType.metricType.tint
						: Color.mint
				)
		}
		.padding(12)
		.background {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(.secondarySystemBackground))
				.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightBarCardView()
		.environment(metricStore)
}
