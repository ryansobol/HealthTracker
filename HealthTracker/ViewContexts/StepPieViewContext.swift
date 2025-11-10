import OrderedCollections
import SwiftUI

struct StepPieViewContext: ChartViewContext {
	let store: StepStore

	var chartView: some View {
		return StepPieChartView(context: self)
	}

	let hasNavigation = false

	var hasData: Bool {
		return !self.store.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 240

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.pie"

	let symbolTitle = "calendar"

	let title = "Averages"
}
