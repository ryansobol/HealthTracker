import SwiftUI

struct MetricCardView<ChartView: View>: View {
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
