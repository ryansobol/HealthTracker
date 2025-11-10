import HealthKit

protocol StoreContext {
	static func selectQuantity(from statistic: HKStatistics) -> Double

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
}
