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
}
