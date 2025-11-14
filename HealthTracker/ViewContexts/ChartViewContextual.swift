import Charts
import SwiftUI

protocol ChartViewContextual {
	associatedtype ChartView: View
	associatedtype MetricStore: MetricStorable

	var chartView: ChartView { get }
	var chartYScale: ClosedRange<Double> { get }
	var hasMetrics: Bool { get }
	var hasNavigation: Bool { get }
	var height: CGFloat { get }
	var metricStore: MetricStore { get }
	var subtitle: String { get }
	var symbolChart: String { get }
	var symbolTitle: String { get }
	var title: String { get }
}

// MARK: - MetricType

extension ChartViewContextual {
	var chartXAxisContent: some AxisContent {
		AxisMarks { _ in
			AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
		}
	}

	var chartYAxisContent: some AxisContent {
		AxisMarks { value in
			AxisGridLine()
				.foregroundStyle(.gray.opacity(0.3))

			AxisValueLabel(
				(value.as(Double.self) ?? 0)
					.formatted(.number.notation(.compactName)),
			)
		}
	}

	var metricType: MetricType {
		return self.metricStore.metricType
	}
}
