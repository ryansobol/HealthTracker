import OrderedCollections
import SwiftUI

struct StepBarCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		let chartType = ChartType.stepBar(averageSteps: self.metricStore.averageSteps)

		ChartCardView(chartType: chartType) {
			Group {
				if self.metricStore.stepDiscreteMetricByDate.isEmpty {
					EmptyChartView(
						title: "No Data",
						systemName: "chart.bar",
						description: "No steps data collected from HealthKit",
					)
				}
				else {
					StepBarChartView(chartType: chartType)
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
