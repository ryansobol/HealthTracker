import SwiftUI

struct MetricCardView<ChartView: View>: View {
	let durationOpacity = 0.15
	let durationScaleEffect = 0.1

	let chartType: ChartType
	let isEmpty: Bool
	let height: CGFloat

	@ViewBuilder let chartView: () -> ChartView

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.isEmpty {
					EmptyChartView(chartType: self.chartType)
				}
				else {
					self.chartView()
				}
			}
			.frame(height: self.height)
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
			height: 150,
		) {
			StepBarChartView(chartType: .stepBar(averageSteps: 10000))
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
