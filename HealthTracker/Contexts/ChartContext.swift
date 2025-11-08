import Foundation
import OrderedCollections

enum ChartContext {
	case stepBar(store: MetricStore)
	case stepPie(store: MetricStore)
	case weightBar(store: MetricStore)
	case weightLine(store: MetricStore)

	var metricType: MetricType {
		return switch self {
		case .stepBar: .steps
		case .stepPie: .steps
		case .weightBar: .weight
		case .weightLine: .weight
		}
	}

	var title: String {
		return switch self {
		case .stepBar: "Steps"
		case .stepPie: "Averages"
		case .weightBar: "Average Change"
		case .weightLine: "Weight"
		}
	}

	var symbolTitle: String {
		return switch self {
		case .stepBar: "figure.walk"
		case .stepPie: "calendar"
		case .weightBar: "figure"
		case .weightLine: "figure"
		}
	}

	var symbolChart: String {
		return switch self {
		case .stepBar: "chart.bar"
		case .stepPie: "chart.pie"
		case .weightBar: "chart.bar"
		case .weightLine: "chart.xyaxis.line"
		}
	}

	var subtitle: String {
		return switch self {
		case let .stepBar(store):
			"Average \(store.averageSteps.formatted(.number.precision(.fractionLength(0)))) steps"

		case .stepPie:
			"Last 28 Days"

		case .weightBar:
			"Last 28 Days"

		case let .weightLine(store):
			"Average \(store.averageWeight.formatted(.number.precision(.fractionLength(1)))) lbs"
		}
	}

	var hasNavigation: Bool {
		return switch self {
		case .stepBar: true
		case .stepPie: false
		case .weightBar: false
		case .weightLine: true
		}
	}

	var height: CGFloat {
		return switch self {
		case .stepBar: 150
		case .stepPie: 240
		case .weightBar: 150
		case .weightLine: 150
		}
	}

	var hasData: Bool {
		return switch self {
		case let .stepBar(store): !store.stepDiscreteMetricByDate.isEmpty
		case let .stepPie(store): !store.stepDiscreteMetricByDate.isEmpty
		case let .weightBar(store): !store.weightDiffAverageMetricByWeekday.isEmpty
		case let .weightLine(store): !store.weightDiscreteMetricByDate.isEmpty
		}
	}

	var store: MetricStore {
		return switch self {
		case let .stepBar(store): store
		case let .stepPie(store): store
		case let .weightBar(store): store
		case let .weightLine(store): store
		}
	}
}
