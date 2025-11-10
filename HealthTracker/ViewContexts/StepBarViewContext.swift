import OrderedCollections
import SwiftUI

struct StepBarViewContext: ChartViewContextual {
	let store: StepStore
	
	var chartView: some View {
		return StepBarChartView(context: self)
	}

	let hasNavigation = true

	var hasData: Bool {
		return !self.store.discreteMetricByDate.isEmpty
	}

	let height: CGFloat = 150

	var subtitle: String {
		let value = self.store.discreteMetricAverage.formatted(.number.precision(.fractionLength(0)))
		let unit = self.title.lowercased()

		return "Average \(value) \(unit)"
	}

	let symbolChart = "chart.bar"

	let symbolTitle = "figure.walk"

	var title: String {
		return self.metricType.title
	}
}
