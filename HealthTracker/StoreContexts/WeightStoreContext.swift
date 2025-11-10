import HealthKit

enum WeightStoreContext: StoreContext {
	static func selectQuantity(from statistic: HKStatistics) -> Double {
		return statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0.0
	}

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
	{
		return zip(discreteMetrics.dropFirst(), discreteMetrics).map { current, previous in
			DiscreteMetric(date: current.date, value: current.value - previous.value)
		}
	}
}
