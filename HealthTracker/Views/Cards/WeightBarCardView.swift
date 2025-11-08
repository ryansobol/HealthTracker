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
