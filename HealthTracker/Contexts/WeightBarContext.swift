import Foundation
import OrderedCollections
import SwiftUI

struct WeightBarContext: ChartContext {
	let store: MetricStore

	let metricType = MetricType.weight
	let title = "Average Change"
	let symbolTitle = "figure"
	let symbolChart = "chart.bar"
	let subtitle = "Last 28 Days"
	let hasNavigation = false
	let height: CGFloat = 150

	var hasData: Bool {
		return !self.store.weightDiffAverageMetricByWeekday.isEmpty
	}

	var chartView: some View {
		return WeightBarChartView(context: self)
	}
}
