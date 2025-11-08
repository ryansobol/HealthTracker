import Charts
import OrderedCollections
import SwiftUI

struct WeightLineCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		let chartType = ChartType.weightLine(averageWeight: self.metricStore.averageWeight)

		ChartCardView(chartType: chartType) {
			Group {
				if self.metricStore.weightDiscreteMetricByDate.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.xyaxis.line",
						description: "No weight data collected from HealthKit",
					)
				}
				else {
					WeightLineChart(chartType: chartType)
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
