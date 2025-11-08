import OrderedCollections
import SwiftUI

struct WeightBarCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(
			chartType: .weightBar,
			isEmpty: self.metricStore.weightDiffAverageMetricByWeekday.isEmpty,
		)
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	WeightBarCardView()
		.environment(metricStore)
}
