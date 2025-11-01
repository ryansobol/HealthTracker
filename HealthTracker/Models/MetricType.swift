import SwiftUI

enum MetricType: CaseIterable, Identifiable {
	case steps
	case weight

	var id: Self {
		return self
	}

	var tint: Color {
		return switch self {
		case .steps: .pink
		case .weight: .indigo
		}
	}
}

extension MetricType: CustomStringConvertible {
	var description: String {
		return switch self {
		case .steps: "Steps"
		case .weight: "Weight"
		}
	}

	var title: String {
		return String(describing: self)
	}
}
