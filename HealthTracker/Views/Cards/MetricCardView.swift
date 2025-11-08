import SwiftUI

struct MetricCardView: View {
	let durationOpacity = 0.15
	let durationScaleEffect = 0.1

	let chartType: ChartType
	let isEmpty: Bool

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.isEmpty {
					EmptyChartView(chartType: self.chartType)
				}
				else {
					self.chartView
				}
			}
			.frame(height: self.chartType.height)
		}
	}

	@ViewBuilder
	private var chartView: some View {
		switch self.chartType {
		case .stepBar: StepBarChartView(chartType: self.chartType)
		case .stepPie: StepPieChartView(chartType: self.chartType)
		case .weightBar: WeightBarChartView(chartType: self.chartType)
		case .weightLine: WeightLineChartView(chartType: self.chartType)
		}
	}
}

#Preview {
	@Previewable @State var isEmpty = true
	@Previewable @State var metricStore = MetricStore()

	VStack {
		MetricCardView(
			chartType: .stepBar(averageSteps: 10000),
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
