import OrderedCollections
import SwiftUI

struct StepBarCardView: View {
	let chartType = ChartType.stepBar

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.metricStore.stepDiscreteMetricByDate.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.bar",
						description: "No steps data collected from HealthKit",
					)
				}
				else {
					StepBarChart(chartType: self.chartType)
				}
			}
			.frame(height: 150)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.environment(metricStore)
}
