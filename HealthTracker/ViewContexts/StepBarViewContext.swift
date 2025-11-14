import OrderedCollections
import SwiftUI

struct StepBarViewContext: ChartViewContextual {
	let metricStore: StepStore

	var accessibilityTitle: String {
		return "\(self.title) Per Day Chart"
	}

	var chartView: some View {
		return StepBarChartView(context: self)
	}

	var chartYScale: ClosedRange<Double> {
		return ClosedRange.forChartAxis(
			min: self.metricStore.discreteMetricMinimum,
			max: self.metricStore.discreteMetricMaximum,
		)
	}

	let hasNavigation = true

	var hasMetrics: Bool {
		return !self.metricStore.discreteMetricByDate.isEmpty
	}

	let height: CGFloat = 150

	var subtitle: String {
		let value = self.metricStore.discreteMetricAverage.formatted(.step)
		let unit = self.metricType.title.lowercased()

		return "Average \(value) \(unit)"
	}

	let symbolChart = "chart.bar"

	let symbolTitle = "figure.walk"

	var title: String {
		return self.metricType.title
	}
}
