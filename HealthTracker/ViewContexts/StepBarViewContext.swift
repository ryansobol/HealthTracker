import OrderedCollections
import SwiftUI

struct StepBarViewContext: ChartViewContext {
	let store: StepStore

	let metricType = MetricType.step
	let title = MetricType.step.title
	let symbolTitle = "figure.walk"
	let symbolChart = "chart.bar"
	let hasNavigation = true
	let height: CGFloat = 150

	var subtitle: String {
		let value = self.store.discreteMetricAverage.formatted(.number.precision(.fractionLength(0)))
		let unit = self.title.lowercased()

		return "Average \(value) \(unit)"
	}

	var hasData: Bool {
		return !self.store.discreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return StepBarChartView(context: self)
	}
}
