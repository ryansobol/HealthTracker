import Foundation

struct HealthMetric: Identifiable {
	let id = UUID()

	let data: Date
	let value: Double
}
