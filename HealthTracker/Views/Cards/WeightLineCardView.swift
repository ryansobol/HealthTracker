import Charts
import OrderedCollections
import SwiftUI

struct WeightLineCardView: View {
	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		MetricCardView(chartContext: .weightLine(store: self.metricStore))
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
