import HealthKit
import Observation
import OrderedCollections

struct HealthKitService {
	private let stepType = HKQuantityType(.stepCount)
	private let weightType = HKQuantityType(.bodyMass)

	let store = HKHealthStore()
	let types: Set<HKQuantityType>

	init() {
		self.types = Set([
			self.stepType,
			self.weightType,
		])
	}

	// MARK: - Authorization

	private func isAuthorizationRequestUnnecessary(for type: HKQuantityType) async throws -> Bool {
		let result = try await self.store.statusForAuthorizationRequest(
			toShare: Set([type]),
			read: Set([type]),
		)

		return result == .unnecessary
	}

	private func isSharingAuthorized(for type: HKQuantityType) -> Bool {
		return self.store.authorizationStatus(for: self.stepType) == .sharingAuthorized
	}

	// MARK: - Fetching

	func fetchStepStatistics() async throws -> [HKStatistics] {
		guard try await self.isAuthorizationRequestUnnecessary(for: self.stepType) else {
			throw AuthorizationRequestNecessaryError(metricType: .steps)
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

		return statisticsCollection.statistics()
	}

	func fetchWeightStatistics() async throws -> [HKStatistics] {
		guard try await self.isAuthorizationRequestUnnecessary(for: self.weightType) else {
			throw AuthorizationRequestNecessaryError(metricType: .weight)
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

		return statisticsCollection.statistics()
	}

	// MARK: - Creation

	func createStepSample(
		metricType: MetricType,
		date: Date,
		value: Double,
	) async throws -> Void {
		guard self.isSharingAuthorized(for: self.stepType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let quantity = HKQuantity(unit: .count(), doubleValue: value)
		let sample = HKQuantitySample(type: self.stepType, quantity: quantity, start: date, end: date)

		try await self.store.save(sample)
	}

	func createWeightSample(
		metricType: MetricType,
		date: Date,
		value: Double,
	) async throws -> Void {
		guard self.isSharingAuthorized(for: self.weightType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let quantity = HKQuantity(unit: .pound(), doubleValue: value)
		let sample = HKQuantitySample(type: self.weightType, quantity: quantity, start: date, end: date)

		try await self.store.save(sample)
	}

	func createFakeSamples() async throws -> Void {
		guard self.isSharingAuthorized(for: self.stepType) else {
			throw AppError.sharingNotAuthorized(metricType: .steps)
		}

		guard self.isSharingAuthorized(for: self.weightType) else {
			throw AppError.sharingNotAuthorized(metricType: .weight)
		}

		let days = 28
		var fakeSamples = [HKQuantitySample]()

		fakeSamples.reserveCapacity(days * 2)

		for i in 0 ..< days {
			let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
			let endDate = Calendar.current.date(byAdding: .second, value: i, to: startDate)!

			let stepQuantity = HKQuantity(
				unit: .count(),
				doubleValue: .random(in: 4000 ... 20000),
			)

			let stepSample = HKQuantitySample(
				type: self.stepType,
				quantity: stepQuantity,
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(stepSample)

			let weightQuantity = HKQuantity(
				unit: .pound(),
				doubleValue: .random(in: 160 + Double(i / 3) ... 165 + Double(i / 3)),
			)

			let weightSample = HKQuantitySample(
				type: self.weightType,
				quantity: weightQuantity,
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(weightSample)
		}

		try! await self.store.save(fakeSamples)
	}
}
