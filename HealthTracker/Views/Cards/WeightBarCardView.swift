import OrderedCollections
import SwiftUI

struct WeightBarCardView: View {
	let chartType = ChartType.weightBar

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(
			chartType: self.chartType,
			isEmpty: self.metricStore.weightDiffAverageMetricByWeekday.isEmpty,
			height: 150,
		) {
			WeightBarChartView(chartType: self.chartType)
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
