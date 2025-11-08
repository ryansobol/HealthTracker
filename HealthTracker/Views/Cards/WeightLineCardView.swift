import Charts
import OrderedCollections
import SwiftUI

struct WeightLineCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		let chartType = ChartType.weightLine(averageWeight: self.metricStore.averageWeight)

		ChartCardView(chartType: chartType) {
			MetricCardView(
				chartType: chartType,
				isEmpty: self.metricStore.weightDiscreteMetricByDate.isEmpty,
				height: 150,
			) {
				WeightLineChartView(chartType: chartType)
			}
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightLineCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightLineCardView()
		.environment(metricStore)
}
