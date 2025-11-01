import SwiftUI

enum MetricType: CaseIterable, Identifiable {
	case steps
	case weight

	var id: Self {
		return self
	}

	var title: String {
		return switch self {
		case .steps: "Steps"
		case .weight: "Weight"
		}
	}

	var tint: Color {
		return switch self {
		case .steps: .pink
		case .weight: .indigo
		}
	}
}
