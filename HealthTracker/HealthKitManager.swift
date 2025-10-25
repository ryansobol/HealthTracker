import HealthKit
import Observation

@Observable
final class HealthKitManager {
	let store = HKHealthStore()
	let types = Set([HKQuantityType(.stepCount), HKQuantityType(.bodyMass)])

	var shouldRequestAuthorization: Bool {
		get async throws {
			let result = try await self.store.statusForAuthorizationRequest(
				toShare: self.types,
				read: self.types,
			)

			return result == .shouldRequest
		}
	}

	var isAuthorizationRequestUnnecessary: Bool {
		get async throws {
			let result = try await self.store.statusForAuthorizationRequest(
				toShare: self.types,
				read: self.types,
			)

			return result == .unnecessary
		}
	}

	func fetchData() async throws -> Void {
		try await self.fetchStepCounts()
		try await self.fetchWeights()
	}

	func fetchStepCounts() async throws -> Void {
		guard try await self.isAuthorizationRequestUnnecessary else {
			return
		}

		let calendar = Calendar.current
		let today = calendar.startOfDay(for: .now)
		let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
		let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)

		let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

		let samplePredicate = HKSamplePredicate.quantitySample(
			type: HKQuantityType(.stepCount),
			predicate: queryPredicate,
		)

		let statisticsCollectionQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: samplePredicate,
			options: .cumulativeSum,
			anchorDate: endDate,
			intervalComponents: .init(day: 1),
		)

		let statisticsCollection = try await statisticsCollectionQuery.result(for: self.store)

		for statistic in statisticsCollection.statistics() {
			print(statistic.sumQuantity() ?? 0)
		}
	}

	func fetchWeights() async throws -> Void {
		guard try await self.isAuthorizationRequestUnnecessary else {
			return
		}

		let calendar = Calendar.current
		let today = calendar.startOfDay(for: .now)
		let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
		let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)

		let queryPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

		let samplePredicate = HKSamplePredicate.quantitySample(
			type: HKQuantityType(.bodyMass),
			predicate: queryPredicate,
		)

		let statisticsCollectionQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: samplePredicate,
			options: .mostRecent,
			anchorDate: endDate,
			intervalComponents: .init(day: 1),
		)

		let statisticsCollection = try await statisticsCollectionQuery.result(for: self.store)

		for statistic in statisticsCollection.statistics() {
			print(statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0)
		}
	}

	func addFakeDataToSimulatorData() async throws -> Void {
		#if !targetEnvironment(simulator)
			return
		#endif

		guard try await self.isAuthorizationRequestUnnecessary else {
			return
		}

		var fakeSamples = [HKQuantitySample]()

		for i in 0 ..< 28 {
			let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
			let endDate = Calendar.current.date(byAdding: .second, value: i, to: startDate)!

			let stepSample = HKQuantitySample(
				type: HKQuantityType(.stepCount),
				quantity: HKQuantity(unit: .count(), doubleValue: .random(in: 4000 ... 20000)),
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(stepSample)

			let weightSample = HKQuantitySample(
				type: HKQuantityType(.bodyMass),
				quantity: HKQuantity(
					unit: .pound(),
					doubleValue: .random(in: 160 + Double(i / 3) ... 165 + Double(i / 3)),
				),
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(weightSample)
		}

		try! await self.store.save(fakeSamples)

		print("--> Fake health data added to simulator")
	}
}
