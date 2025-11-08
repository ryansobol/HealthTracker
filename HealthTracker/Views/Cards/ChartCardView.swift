import SwiftUI

struct ChartCardView: View {
	private let durationOpacity = 0.15
	private let durationScaleEffect = 0.1

	let context: ChartContext

	var body: some View {
		ChartContentCardView(context: self.context) {
			Group {
				if self.context.hasData {
					self.chartView
				}
				else {
					EmptyChartView(context: self.context)
				}
			}
			.frame(height: self.context.height)
		}
	}

	@ViewBuilder
	private var chartView: some View {
		switch self.context {
		case .stepBar: StepBarChartView(context: self.context)
		case .stepPie: StepPieChartView(context: self.context)
		case .weightBar: WeightBarChartView(context: self.context)
		case .weightLine: WeightLineChartView(context: self.context)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var metricStore = MetricStore()

	VStack {
		ChartCardView(context: .stepBar(store: metricStore))
	}
	.task {
		try! await metricStore.fetchMetrics()
	}
	.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	VStack {
		ChartCardView(context: .stepBar(store: metricStore))
	}
}
