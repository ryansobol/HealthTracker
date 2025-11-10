import HealthKit
import SwiftUI

// MARK: - CaseIterable, Identifiable

enum MetricType: CaseIterable, Identifiable {
	case steps
	case weight

	var id: Self {
		return self
	}
}

// MARK: - CustomStringConvertible

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

// MARK: - HealthKit

extension MetricType {
	nonisolated var unit: HKUnit {
		return switch self {
		case .steps: .count()
		case .weight: .pound()
		}
	}

	nonisolated var quantityType: HKQuantityType {
		return switch self {
		case .steps: HKQuantityType(.stepCount)
		case .weight: HKQuantityType(.bodyMass)
		}
	}

	nonisolated var statisticsOptions: HKStatisticsOptions {
		return switch self {
		case .steps: .cumulativeSum
		case .weight: .mostRecent
		}
	}

	func quantity(for statistics: HKStatistics) -> Double {
		return switch self {
		case .steps: statistics.sumQuantity()?.doubleValue(for: self.unit) ?? 0.0
		case .weight: statistics.mostRecentQuantity()?.doubleValue(for: self.unit) ?? 0.0
		}
	}
}

// MARK: - SwiftUI

extension MetricType {
	var color: Color {
		return switch self {
		case .steps: .pink
		case .weight: .indigo
		}
	}
}
