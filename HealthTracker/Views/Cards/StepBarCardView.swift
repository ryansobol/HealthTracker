import OrderedCollections
import SwiftUI

struct StepBarCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		let chartType = ChartType.stepBar(averageSteps: self.metricStore.averageSteps)

		MetricCardView(
			chartType: chartType,
			isEmpty: self.metricStore.stepDiscreteMetricByDate.isEmpty,
		) {
			StepBarChartView(chartType: chartType)
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
