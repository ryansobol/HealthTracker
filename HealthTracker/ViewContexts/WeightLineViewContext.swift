import OrderedCollections
import SwiftUI

struct WeightLineViewContext: ChartViewContextual {
	let metricStore: WeightStore

	var accessibilityTitle: String {
		return "\(self.title) by day chart"
	}

	var chartView: some View {
		return WeightLineChartView(context: self)
	}

	var chartYScale: ClosedRange<Double> {
		return ClosedRange.forChartAxis(
			min: self.metricStore.discreteMetricMinimum,
			max: self.metricStore.discreteMetricMaximum,
		)
	}

	var hasMetrics: Bool {
		return !self.metricStore.discreteMetricByDate.isEmpty
	}

	let hasNavigation = true

	let height: CGFloat = 150

	var subtitle: String {
		let value = self.metricStore.discreteMetricAverage.formatted(.weight)
		let unit = self.metricType.unitName

		return "Average \(value) \(unit)"
	}

	let symbolChart = "chart.xyaxis.line"

	let symbolTitle = "figure"

	var title: String {
		return self.metricType.title
	}
}
