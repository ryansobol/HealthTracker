import HealthKit

enum WeightStoreContext: StoreContext {
	static let serviceContext = HealthKitServiceContext.weight

	static func selectQuantity(from statistic: HKStatistics) -> Double {
		return statistic.mostRecentQuantity()?.doubleValue(for: self.serviceContext.unit) ?? 0.0
	}

	static func selectDiscreteMetricsForAveraging(from discreteMetrics: [DiscreteMetric])
		-> [DiscreteMetric]
	{
		return zip(discreteMetrics.dropFirst(), discreteMetrics).map { current, previous in
			DiscreteMetric(date: current.date, value: current.value - previous.value)
		}
	}

	static func generateFakeValue(for day: Int) -> Double {
		return .random(in: 160 + Double(day / 3) ... 165 + Double(day / 3))
	}
}
