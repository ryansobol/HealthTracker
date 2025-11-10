import HealthKit

enum StepStoreContext: StoreContext {
	static let metricType = MetricType.steps

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
	{
		return discreteMetrics
	}

	static func generateFakeValue(for _: Int) -> Double {
		return .random(in: 4000 ... 20000)
	}
}
