import OrderedCollections
import SwiftUI

struct StepPieCardView: View {
	let chartType = ChartType.stepPie

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.metricStore.stepDiscreteMetricByDate.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.pie",
						description: "No steps data collected from HealthKit",
					)
				}
				else {
					StepPieChart(chartType: self.chartType)
				}
			}
			.frame(height: 240)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepPieCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepPieCardView()
		.environment(metricStore)
}
