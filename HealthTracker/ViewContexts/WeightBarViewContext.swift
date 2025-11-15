import OrderedCollections
import SwiftUI

struct WeightBarViewContext: ChartViewContextual {
	let metricStore: WeightStore

	var accessibilityTitle: String {
		return "\(self.title) by weekday chart"
	}

	var chartView: some View {
		return WeightBarChartView(context: self)
	}

	var chartYScale: ClosedRange<Double> {
		return ClosedRange.forChartAxis(
			min: self.metricStore.averageMetricMinimum,
			max: self.metricStore.averageMetricMaximum,
		)
	}

	let hasNavigation = false

	var hasMetrics: Bool {
		return !self.metricStore.averageMetricByWeekday.isEmpty
	}

	let height: CGFloat = 150

	let subtitle = "Last 28 Days"

	let symbolChart = "chart.bar"

	let symbolTitle = "calendar"

	let title = "Average Weight Change"
}
