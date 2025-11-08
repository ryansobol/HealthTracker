import Charts
import OrderedCollections
import SwiftUI

struct WeightLineCardView: View {
	let chartType = ChartType.weightLine

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.metricStore.weightDiscreteMetricByDate.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.xyaxis.line",
						description: "No weight data collected from HealthKit",
					)
				}
				else {
					WeightLineChart(chartType: self.chartType)
				}
			}
			.frame(height: 150)
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
