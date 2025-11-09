import OrderedCollections
import SwiftUI

struct StepPieViewContext: ChartViewContext {
	let store: StepStore

	let metricType = MetricType.steps
	let title = "Averages"
	let symbolTitle = "calendar"
	let symbolChart = "chart.pie"
	let subtitle = "Last 28 Days"
	let hasNavigation = false
	let height: CGFloat = 240

	var hasData: Bool {
		return !self.store.averageMetricByWeekday.isEmpty
	}

	var chartView: some View {
		return StepPieChartView(context: self)
	}
}
