import HealthKit

struct HealthKitServiceContext {
	let quantityType: HKQuantityType
	let unit: HKUnit
	let statisticsOptions: HKStatisticsOptions
	let fakeValueGenerator: (Int) -> Double

	static let steps = Self(
		quantityType: HKQuantityType(.stepCount),
		unit: .count(),
		statisticsOptions: .cumulativeSum,
		fakeValueGenerator: { _ in .random(in: 4000 ... 20000) },
	)

	static let weight = Self(
		quantityType: HKQuantityType(.bodyMass),
		unit: .pound(),
		statisticsOptions: .mostRecent,
		fakeValueGenerator: { day in .random(in: 160 + Double(day / 3) ... 165 + Double(day / 3)) },
	)
}
