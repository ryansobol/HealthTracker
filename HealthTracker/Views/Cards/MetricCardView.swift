import SwiftUI

struct MetricCardView: View {
	let durationOpacity = 0.15
	let durationScaleEffect = 0.1

	let chartContext: ChartContext
	let isEmpty: Bool

	var body: some View {
		ChartCardView(chartContext: self.chartContext) {
			Group {
				if self.isEmpty {
					EmptyChartView(chartContext: self.chartContext)
				}
				else {
					self.chartView
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

#Preview {
	@Previewable @State var isEmpty = true
	@Previewable @State var metricStore = MetricStore()

	VStack {
		MetricCardView(
			chartContext: .stepBar(store: metricStore),
			isEmpty: isEmpty,
		)

		Button("Toggle") {
			isEmpty.toggle()
		}
		.buttonStyle(.borderedProminent)
	}
	.task {
		try! await metricStore.fetchMetrics()
	}
	.environment(metricStore)
}
