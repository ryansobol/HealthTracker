import HealthKit

protocol StoreContext {
	static var metricType: MetricType { get }

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]

	static func generateFakeValue(for day: Int) -> Double
}
