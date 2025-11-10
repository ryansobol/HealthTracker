import HealthKit

enum StepStoreContext: MetricStoreContextual {
	static let metricType = MetricType.step

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
	{
		return discreteMetrics
	}

	static func generateFakeValue(for _: Int) -> Double {
		return .random(in: 4000 ... 20000)
	}
}
