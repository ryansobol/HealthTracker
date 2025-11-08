import OrderedCollections
import SwiftUI

struct StepPieCardView: View {
	let chartType = ChartType.stepPie

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(
			chartType: self.chartType,
			isEmpty: self.metricStore.stepDiscreteMetricByDate.isEmpty,
			height: 240,
		) {
			StepPieChartView(chartType: self.chartType)
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
