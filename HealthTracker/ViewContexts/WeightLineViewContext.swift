import HealthKit
import OrderedCollections
import SwiftUI

struct WeightLineViewContext: ChartViewContext {
	let store: WeightStore
	
	var chartView: some View {
		return WeightLineChartView(context: self)
	}

	var hasData: Bool {
		return !self.store.discreteMetricByDate.isEmpty
	}

	let hasNavigation = true

	let height: CGFloat = 150

	var subtitle: String {
		let value = self.store.discreteMetricAverage.formatted(.number.precision(.fractionLength(1)))
		let unit = self.metricType.unit.unitString

		return "Average \(value) \(unit)"
	}

	let symbolChart = "chart.xyaxis.line"

	let symbolTitle = "figure"

	var title: String {
		return self.metricType.title
	}
}
