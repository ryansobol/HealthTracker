import SwiftUI

struct ChartCardView<Context: ChartViewContext>: View {
	let context: Context

	var body: some View {
		ChartContentCardView(context: self.context) {
			Group {
				if self.context.hasData {
					self.context.chartView
				}
				else {
					EmptyChartView(context: self.context)
				}
			}
			.frame(height: self.context.height)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	ChartCardView(context: StepBarViewContext(store: metricStore))
		.task {
			try! await metricStore.fetchMetrics()
		}
}

#Preview("Without Metrics") {
	ChartCardView(context: StepBarViewContext(store: MetricStore()))
}
