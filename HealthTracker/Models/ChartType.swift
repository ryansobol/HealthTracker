enum ChartType {
	case stepBar
	case stepPie
	case weightBar
	case weightLine

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

	var subtitle: String {
		return switch self {
		case .stepBar: "Last 28 Days"
		case .stepPie: "Last 28 Days"
		case .weightBar: "Last 28 Days"
		case .weightLine: "Avg: 180 lbs"
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
