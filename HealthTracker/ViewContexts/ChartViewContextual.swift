import SwiftUI

protocol ChartViewContextual {
	associatedtype ChartView: View
	associatedtype Store: MetricStorable

	var chartView: ChartView { get }
	var hasData: Bool { get }
	var hasNavigation: Bool { get }
	var height: CGFloat { get }
	var store: Store { get }
	var subtitle: String { get }
	var symbolChart: String { get }
	var symbolTitle: String { get }
	var title: String { get }
}

// MARK: - MetricType

extension ChartViewContextual {
	var metricType: MetricType {
		return self.store.metricType
	}
}
