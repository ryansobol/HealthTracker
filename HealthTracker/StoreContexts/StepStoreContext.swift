import HealthKit

enum StepStoreContext: StoreContext {
	static func selectQuantity(from statistic: HKStatistics) -> Double {
		return statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0.0
	}
}
