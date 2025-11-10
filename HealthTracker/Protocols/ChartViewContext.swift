import SwiftUI

protocol ChartViewContext {
	associatedtype Store: MetricStore
	associatedtype ChartView: View

	var store: Store { get }
	var title: String { get }
	var symbolTitle: String { get }
	var symbolChart: String { get }
	var subtitle: String { get }
	var hasNavigation: Bool { get }
	var height: CGFloat { get }
	var hasData: Bool { get }
	var chartView: ChartView { get }
}

extension ChartViewContext {
	var metricType: MetricType {
		return self.store.metricType
	}
}
