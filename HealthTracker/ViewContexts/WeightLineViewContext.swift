import Foundation
import OrderedCollections
import SwiftUI

struct WeightLineViewContext: ChartViewContext {
	let store: MetricStore

	let metricType = MetricType.weight
	let title = "Weight"
	let symbolTitle = "figure"
	let symbolChart = "chart.xyaxis.line"
	let hasNavigation = true
	let height: CGFloat = 150

	var subtitle: String {
		return "Average \(self.store.averageWeight.formatted(.number.precision(.fractionLength(1)))) lbs"
	}

	var hasData: Bool {
		return !self.store.weightDiscreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return WeightLineChartView(context: self)
	}
}
