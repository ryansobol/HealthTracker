import OrderedCollections
import SwiftUI

struct StepBarCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(
			chartType: .stepBar(averageSteps: self.metricStore.averageSteps),
			isEmpty: self.metricStore.stepDiscreteMetricByDate.isEmpty,
		)
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
