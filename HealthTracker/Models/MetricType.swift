import HealthKit
import SwiftUI

// MARK: - CaseIterable, Identifiable

enum MetricType: CaseIterable, Identifiable {
	case step
	case weight

	var id: Self {
		return self
	}
}

// MARK: - CustomStringConvertible

extension MetricType: CustomStringConvertible {
	var description: String {
		return switch self {
		case .step: "Steps"
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
		case .step: .count()
		case .weight: .pound()
		}
	}

	var unitName: String {
		return self.unit.unitString
	}

	nonisolated var quantityType: HKQuantityType {
		return switch self {
		case .step: HKQuantityType(.stepCount)
		case .weight: HKQuantityType(.bodyMass)
		}
	}

	nonisolated var statisticsOptions: HKStatisticsOptions {
		return switch self {
		case .step: .cumulativeSum
		case .weight: .mostRecent
		}
	}

	func quantity(for statistics: HKStatistics) -> Double {
		return switch self {
		case .step: statistics.sumQuantity()?.doubleValue(for: self.unit) ?? 0.0
		case .weight: statistics.mostRecentQuantity()?.doubleValue(for: self.unit) ?? 0.0
		}
	}
}

// MARK: - SwiftUI

extension MetricType {
	var color: Color {
		return switch self {
		case .step: .pink
		case .weight: .indigo
		}
	}
}
