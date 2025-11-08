import SwiftUI

struct EmptyChartView: View {
	let chartContext: ChartContext

	var body: some View {
		ContentUnavailableView {
			Image(systemName: self.chartContext.chartSymbol)
				.font(.largeTitle)
				.foregroundStyle(.secondary)
				.padding(.bottom, 4)

			Text("No Data")
				.font(.callout.bold())

			Text("No \(self.chartContext.metricType.title.lowercased()) data collected from HealthKit")
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	EmptyChartView(chartContext: .stepPie)
}
