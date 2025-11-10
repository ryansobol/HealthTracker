import HealthKit

enum WeightStoreContext: StoreContext {
	static func selectQuantity(from statistic: HKStatistics) -> Double {
		return statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0.0
	}
}
