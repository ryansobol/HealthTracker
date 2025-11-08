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
			ZStack {
				EmptyChartView(chartType: self.chartType)
					.opacity(self.isEmpty ? 1 : 0)

				self.chartView()
					.scaleEffect(self.isEmpty ? 0.9 : 1.0)
					.animation(.bouncy(duration: self.durationScaleEffect), value: self.isEmpty)
					.opacity(self.isEmpty ? 0 : 1)

			}
			.frame(height: self.height)
			.animation(.smooth(duration: self.durationOpacity).delay(0.2), value: self.isEmpty)
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
