import Foundation
import OrderedCollections
import SwiftUI

struct StepPieContext: ChartContext {
	let store: MetricStore

	let metricType = MetricType.steps
	let title = "Averages"
	let symbolTitle = "calendar"
	let symbolChart = "chart.pie"
	let subtitle = "Last 28 Days"
	let hasNavigation = false
	let height: CGFloat = 240

	var hasData: Bool {
		return !self.store.stepDiscreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return StepPieChartView(context: self)
	}
}
