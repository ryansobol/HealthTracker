import Foundation

struct DiscreteMetric: Identifiable, Equatable {
	let id = UUID()

	let date: Date
	let value: Double
}
