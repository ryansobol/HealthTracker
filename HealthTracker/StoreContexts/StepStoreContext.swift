import HealthKit

enum StepStoreContext: StoreContext {
	static let serviceContext = HealthKitServiceContext.steps

	static func selectQuantity(from statistic: HKStatistics) -> Double {
		return statistic.sumQuantity()?.doubleValue(for: self.serviceContext.unit) ?? 0.0
	}

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
	{
		return discreteMetrics
	}

	static func generateFakeValue(for _: Int) -> Double {
		return .random(in: 4000 ... 20000)
	}
}
