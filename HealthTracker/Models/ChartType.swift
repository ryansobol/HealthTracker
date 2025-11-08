import Foundation

enum ChartType {
	case stepBar(averageSteps: Double)
	case stepPie
	case weightBar
	case weightLine(averageWeight: Double)

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

	var symbol: String {
		return switch self {
		case .stepBar: "figure.walk"
		case .stepPie: "calendar"
		case .weightBar: "figure"
		case .weightLine: "figure"
		}
	}

	var chartSymbol: String {
		return switch self {
		case .stepBar: "chart.bar"
		case .stepPie: "chart.pie"
		case .weightBar: "chart.bar"
		case .weightLine: "chart.xyaxis.line"
		}
	}

	var subtitle: String {
		return switch self {
		case let .stepBar(averageSteps):
			"Average \(averageSteps.formatted(.number.precision(.fractionLength(0)))) steps"

		case .stepPie:
			"Last 28 Days"

		case .weightBar:
			"Last 28 Days"

		case let .weightLine(averageWeight):
			"Average \(averageWeight.formatted(.number.precision(.fractionLength(1)))) lbs"
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
}
