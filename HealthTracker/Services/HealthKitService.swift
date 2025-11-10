import HealthKit

struct HealthKitService {
	// MARK: - Properties

	let context: HealthKitServiceContext
	let store: HKHealthStore

	init(store: HKHealthStore, context: HealthKitServiceContext) {
		self.context = context
		self.store = store
	}

	// MARK: - Authorization

	private var isAuthorizationRequestUnnecessary: Bool {
		get async throws {
			let types = Set([self.context.quantityType])
			let result = try await self.store.statusForAuthorizationRequest(toShare: types, read: types)

			return result == .unnecessary
		}
	}

	private nonisolated var isSharingAuthorized: Bool {
		return self.store.authorizationStatus(for: self.context.quantityType) == .sharingAuthorized
	}

	// MARK: - Fetching

	@concurrent
	func fetchStatistics(daysAgo: Int) async throws -> [HKStatistics] {
		guard try await self.isAuthorizationRequestUnnecessary else {
			throw AuthorizationRequestNecessaryError(metricType: self.context.metricType)
		}

		let today = Date.now

		guard let dateInterval = DateInterval(from: today, daysAgo: daysAgo) else {
			fatalError("No date interval from \(today) to \(daysAgo) days ago")
		}

		let queryPredicate = HKQuery.predicateForSamples(
			withStart: dateInterval.start,
			end: dateInterval.end,
		)

		let samplePredicate = HKSamplePredicate.quantitySample(
			type: self.context.quantityType,
			predicate: queryPredicate,
		)

		let statisticsCollectionQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: samplePredicate,
			options: self.context.statisticsOptions,
			anchorDate: dateInterval.end,
			intervalComponents: .init(day: 1),
		)

		let statisticsCollection = try await statisticsCollectionQuery.result(for: self.store)

		return statisticsCollection.statistics()
	}

	// MARK: - Building

	private nonisolated func buildQuantitySample(date: Date, value: Double) -> HKQuantitySample {
		let quantity = HKQuantity(unit: self.context.unit, doubleValue: value)

		return HKQuantitySample(
			type: self.context.quantityType,
			quantity: quantity,
			start: date,
			end: date,
		)
	}

	// MARK: - Creation

	@concurrent
	func createSample(date: Date, value: Double) async throws -> Void {
		guard self.isSharingAuthorized else {
			throw AppError.sharingNotAuthorized(metricType: self.context.metricType)
		}

		let quantitySample = self.buildQuantitySample(date: date, value: value)

		try await self.store.save(quantitySample)
	}

	@concurrent
	func createSamples(_ samples: [(date: Date, value: Double)]) async throws -> Void {
		guard self.isSharingAuthorized else {
			throw AppError.sharingNotAuthorized(metricType: self.context.metricType)
		}

		let quantitySamples = samples.map { self.buildQuantitySample(date: $0, value: $1) }

		try await self.store.save(quantitySamples)
	}
}
