import Foundation
import OrderedCollections
import SwiftUI

struct StepBarViewContext: ChartViewContext {
	let store: MetricStore

	let metricType = MetricType.steps
	let title = "Steps"
	let symbolTitle = "figure.walk"
	let symbolChart = "chart.bar"
	let hasNavigation = true
	let height: CGFloat = 150

	var subtitle: String {
		return "Average \(self.store.averageSteps.formatted(.number.precision(.fractionLength(0)))) steps"
	}

	var hasData: Bool {
		return !self.store.stepDiscreteMetricByDate.isEmpty
	}

	var chartView: some View {
		return StepBarChartView(context: self)
	}
}
