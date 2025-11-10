import HealthKit

protocol StoreContext {
	static var serviceContext: HealthKitServiceContext { get }

	static func selectQuantity(from statistic: HKStatistics) -> Double

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]

	static func generateFakeValue(for day: Int) -> Double
}
