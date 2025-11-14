import OrderedCollections
import SwiftUI

struct StepPieViewContext: ChartViewContextual {
	let metricStore: StepStore

	var chartView: some View {
		return StepPieChartView(context: self)
	}

	var chartYScale: ClosedRange<Double> {
		return 0 ... 0
	}

	let hasNavigation = false

	var hasMetrics: Bool {
		return !self.metricStore.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 240

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.pie"

	let symbolTitle = "calendar"

	let title = "Averages"
}
