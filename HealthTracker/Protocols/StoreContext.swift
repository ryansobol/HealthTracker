import HealthKit

protocol StoreContext {
	static func selectQuantity(from statistic: HKStatistics) -> Double
}
