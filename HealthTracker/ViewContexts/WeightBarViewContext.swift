import OrderedCollections
import SwiftUI

struct WeightBarViewContext: ChartViewContext {
	let store: WeightStore
	
	var chartView: some View {
		return WeightBarChartView(context: self)
	}

	let hasNavigation = false

	var hasData: Bool {
		return !self.store.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 150

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.bar"

	let symbolTitle = "figure"

	let title = "Average Change"
}
