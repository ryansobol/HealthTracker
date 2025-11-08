import SwiftUI

struct EmptyChartView: View {
	let context: ChartContext

	var body: some View {
		ContentUnavailableView {
			Image(systemName: self.context.symbolChart)
				.font(.largeTitle)
				.foregroundStyle(.secondary)
				.padding(.bottom, 4)

			Text("No Data")
				.font(.callout.bold())

			Text("No \(self.context.metricType.title.lowercased()) data collected from HealthKit")
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	@Previewable @State var metricStore = MetricStore()

	EmptyChartView(context: .stepPie(store: metricStore))
}
