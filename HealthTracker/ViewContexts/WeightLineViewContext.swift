import HealthKit
import OrderedCollections
import SwiftUI

struct WeightLineViewContext: ChartViewContext {
	let store: WeightStore

	let metricType = MetricType.weight
	let title = MetricType.weight.title
	let symbolTitle = "figure"
	let symbolChart = "chart.xyaxis.line"
	let hasNavigation = true
	let height: CGFloat = 150

	var subtitle: String {
		let value = self.store.discreteMetricAverage.formatted(.number.precision(.fractionLength(1)))
		let unit = self.metricType.unit.unitString

		return "Average \(value) \(unit)"
	}

	var hasData: Bool {
		return !self.store.discreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return WeightLineChartView(context: self)
	}
}
