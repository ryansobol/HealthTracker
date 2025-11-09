import Foundation
import OrderedCollections
import SwiftUI

protocol ChartViewContext {
	associatedtype Store: MetricStore
	var store: Store { get }

	var metricType: MetricType { get }
	var title: String { get }
	var symbolTitle: String { get }
	var symbolChart: String { get }
	var subtitle: String { get }
	var hasNavigation: Bool { get }
	var height: CGFloat { get }
	var hasData: Bool { get }

	associatedtype ChartView: View
	var chartView: ChartView { get }
}
