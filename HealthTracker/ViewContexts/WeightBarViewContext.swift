import OrderedCollections
import SwiftUI

struct WeightBarViewContext: ChartViewContextual {
	let metricStore: WeightStore

	var chartView: some View {
		return WeightBarChartView(context: self)
	}

	let hasNavigation = false

	var hasMetrics: Bool {
		return !self.metricStore.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 150

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.bar"

	let symbolTitle = "figure"

	let title = "Average Change"
}
