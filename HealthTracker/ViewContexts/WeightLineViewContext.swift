import OrderedCollections
import SwiftUI

struct WeightLineViewContext: ChartViewContext {
	let store: WeightStore

	let metricType = MetricType.weight
	let title = "Weight"
	let symbolTitle = "figure"
	let symbolChart = "chart.xyaxis.line"
	let hasNavigation = true
	let height: CGFloat = 150

	var subtitle: String {
		return "Average \(self.store.average.formatted(.number.precision(.fractionLength(1)))) lbs"
	}

	var hasData: Bool {
		return !self.store.discreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return WeightLineChartView(context: self)
	}
}
