import HealthKit

struct HealthKitService {
	// MARK: - Stored Properties

	let metricType: MetricType
	let store: HKHealthStore

	init(metricType: MetricType, store: HKHealthStore) {
		self.metricType = metricType
		self.store = store
	}

	// MARK: - Authorization

	private var isAuthorizationRequestUnnecessary: Bool {
		get async throws {
			let types = Set([self.metricType.quantityType])

			let status: HKAuthorizationRequestStatus

			do {
				status = try await self.store.statusForAuthorizationRequest(toShare: types, read: types)
			}
			catch {
				throw HealthKitError.caught(underlyingError: error)
			}

			return status == .unnecessary
		}
	}

	private nonisolated var isSharingAuthorized: Bool {
		return self.store.authorizationStatus(for: self.metricType.quantityType) == .sharingAuthorized
	}

	// MARK: - Fetching

	@concurrent
	func fetchStatistics(daysAgo: Int) async throws -> [HKStatistics] {
		guard try await self.isAuthorizationRequestUnnecessary else {
			throw AuthorizationRequestNecessaryError(metricType: self.metricType)
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
			type: self.metricType.quantityType,
			predicate: queryPredicate,
		)

		let statisticsCollectionQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: samplePredicate,
			options: self.metricType.statisticsOptions,
			anchorDate: dateInterval.end,
			intervalComponents: .init(day: 1),
		)

		let statisticsCollection: HKStatisticsCollection

		do {
			statisticsCollection = try await statisticsCollectionQuery.result(for: self.store)
		}
		catch {
			throw HealthKitError.caught(underlyingError: error)
		}

		return statisticsCollection.statistics()
	}

	// MARK: - Building

	private nonisolated func buildQuantitySample(date: Date, value: Double) -> HKQuantitySample {
		let quantity = HKQuantity(unit: self.metricType.unit, doubleValue: value)

		return HKQuantitySample(
			type: self.metricType.quantityType,
			quantity: quantity,
			start: date,
			end: date,
		)
	}

	// MARK: - Creation

	@concurrent
	func createSample(date: Date, value: Double) async throws -> Void {
		guard self.isSharingAuthorized else {
			throw HealthKitError.sharingNotAuthorized(metricType: self.metricType)
		}

		let quantitySample = self.buildQuantitySample(date: date, value: value)

		do {
			try await self.store.save(quantitySample)
		}
		catch {
			throw HealthKitError.caught(underlyingError: error)
		}
	}

	@concurrent
	func createSamples(_ samples: [(date: Date, value: Double)]) async throws -> Void {
		guard self.isSharingAuthorized else {
			throw HealthKitError.sharingNotAuthorized(metricType: self.metricType)
		}

		let quantitySamples = samples.map { self.buildQuantitySample(date: $0, value: $1) }

		do {
			try await self.store.save(quantitySamples)
		}
		catch {
			throw HealthKitError.caught(underlyingError: error)
		}
	}
}
