import OrderedCollections
import SwiftUI

struct StepBarViewContext: ChartViewContextual {
	let metricStore: StepStore

	var chartView: some View {
		return StepBarChartView(context: self)
	}

	let hasNavigation = true

	var hasMetrics: Bool {
		return !self.metricStore.discreteMetricByDate.isEmpty
	}

	let height: CGFloat = 150

	var subtitle: String {
		let value = self.metricStore.discreteMetricAverage
			.formatted(.number.precision(.fractionLength(0)))

		let unit = self.title.lowercased()

		return "Average \(value) \(unit)"
	}

	let symbolChart = "chart.bar"

	let symbolTitle = "figure.walk"

	var title: String {
		return self.metricType.title
	}
}
