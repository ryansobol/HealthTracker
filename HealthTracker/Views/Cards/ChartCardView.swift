import SwiftUI

struct ChartCardView<Context: ChartViewContextual>: View {
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
	@Previewable @State var stepStore = StepStore()

	ChartCardView(context: StepBarViewContext(store: stepStore))
		.task {
			try! await stepStore.fetchMetrics()
		}
}

#Preview("Without Metrics") {
	ChartCardView(context: StepBarViewContext(store: StepStore()))
}
