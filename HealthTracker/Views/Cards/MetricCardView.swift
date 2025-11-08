import SwiftUI

struct MetricCardView: View {
	let durationOpacity = 0.15
	let durationScaleEffect = 0.1

	let chartContext: ChartContext

	var body: some View {
		ChartCardView(chartContext: self.chartContext) {
			Group {
				if self.chartContext.hasData {
					self.chartView
				}
				else {
					EmptyChartView(chartContext: self.chartContext)
				}
			}
			.frame(height: self.chartContext.height)
		}
	}

	@ViewBuilder
	private var chartView: some View {
		switch self.chartContext {
		case .stepBar: StepBarChartView(chartContext: self.chartContext)
		case .stepPie: StepPieChartView(chartContext: self.chartContext)
		case .weightBar: WeightBarChartView(chartContext: self.chartContext)
		case .weightLine: WeightLineChartView(chartContext: self.chartContext)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	VStack {
		MetricCardView(chartContext: .stepBar(store: metricStore))
	}
	.task {
		try! await metricStore.fetchMetrics()
	}
	.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	VStack {
		MetricCardView(chartContext: .stepBar(store: metricStore))
	}
}
