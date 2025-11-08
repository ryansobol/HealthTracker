import OrderedCollections
import SwiftUI

struct StepPieCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(
			chartContext: .stepPie,
			isEmpty: self.metricStore.stepDiscreteMetricByDate.isEmpty,
		)
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
