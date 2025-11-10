import HealthKit

struct HealthKitServiceContext {
	let metricType: MetricType
	let quantityType: HKQuantityType
	let unit: HKUnit
	let statisticsOptions: HKStatisticsOptions

	static let steps = Self(
		metricType: .steps,
		quantityType: HKQuantityType(.stepCount),
		unit: .count(),
		statisticsOptions: .cumulativeSum,
	)

	static let weight = Self(
		metricType: .weight,
		quantityType: HKQuantityType(.bodyMass),
		unit: .pound(),
		statisticsOptions: .mostRecent,
	)
}
