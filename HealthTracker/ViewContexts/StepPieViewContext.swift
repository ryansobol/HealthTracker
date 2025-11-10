import OrderedCollections
import SwiftUI

struct StepPieViewContext: ChartViewContextual {
	let store: StepStore

	var chartView: some View {
		return StepPieChartView(context: self)
	}

	let hasNavigation = false

	var hasMetrics: Bool {
		return !self.store.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 240

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.pie"

	let symbolTitle = "calendar"

	let title = "Averages"
}
