import SwiftUI

struct MetricCardView<ChartView: View>: View {
	let durationOpacity = 0.15
	let durationScaleEffect = 0.1

	let chartType: ChartType
	let isEmpty: Bool

	@ViewBuilder let chartView: (ChartType) -> ChartView

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.isEmpty {
					EmptyChartView(chartType: self.chartType)
				}
				else {
					self.chartView(self.chartType)
				}
			}
			.frame(height: self.chartType.height)
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
		) {
			StepBarChartView(chartType: $0)
		}

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
