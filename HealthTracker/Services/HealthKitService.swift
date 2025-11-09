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

	private func isAuthorizationRequestUnnecessary(for type: HKQuantityType) async throws -> Bool {
		let result = try await self.store.statusForAuthorizationRequest(
			toShare: Set([type]),
			read: Set([type]),
		)

		return result == .unnecessary
	}

	private nonisolated func isSharingAuthorized(for type: HKQuantityType) -> Bool {
		return self.store.authorizationStatus(for: type) == .sharingAuthorized
	}

	// MARK: - Fetching

	@concurrent
	func fetchStepStatistics(daysAgo: Int) async throws -> [HKStatistics] {
		return try await self.fetchStatistics(for: .steps, daysAgo: daysAgo)
	}

	@concurrent
	func fetchWeightStatistics(daysAgo: Int) async throws -> [HKStatistics] {
		return try await self.fetchStatistics(for: .weight, daysAgo: daysAgo)
	}

	private func fetchStatistics(for metricType: MetricType, daysAgo: Int)
		async throws -> [HKStatistics]
	{
		guard try await self.isAuthorizationRequestUnnecessary(for: self.context.quantityType) else {
			throw AuthorizationRequestNecessaryError(metricType: metricType)
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

	// MARK: - Creation

	@concurrent
	func createStepSample(date: Date, value: Double) async throws -> Void {
		try await self.createSample(metricType: .steps, date: date, value: value)
	}

	@concurrent
	func createWeightSample(date: Date, value: Double) async throws -> Void {
		try await self.createSample(metricType: .weight, date: date, value: value)
	}

	private func createSample(metricType: MetricType, date: Date, value: Double) async throws -> Void {
		guard self.isSharingAuthorized(for: self.context.quantityType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let sample = self.buildSample(config: self.context, date: date, value: value)

		try await self.store.save(sample)
	}

	private func buildSample(config: HealthKitServiceContext, date: Date, value: Double) -> HKQuantitySample {
		let quantity = HKQuantity(unit: config.unit, doubleValue: value)

		return HKQuantitySample(
			type: config.quantityType,
			quantity: quantity,
			start: date,
			end: date,
		)
	}

	// MARK: - Fake Data Creation

	@concurrent
	func createFakeStepSamples(daysAgo: Int) async throws -> Void {
		try await self.createFakeSamples(metricType: .steps, daysAgo: daysAgo)
	}

	@concurrent
	func createFakeWeightSamples(daysAgo: Int) async throws -> Void {
		try await self.createFakeSamples(metricType: .weight, daysAgo: daysAgo)
	}

	func createFakeSamples(metricType: MetricType, daysAgo: Int) async throws -> Void {
		guard self.isSharingAuthorized(for: self.context.quantityType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let today = Date.now

		var quantitySamples = [HKQuantitySample]()

		quantitySamples.reserveCapacity(daysAgo)

		let fakeQuantitySamples = (0 ..< daysAgo).reduce(into: quantitySamples) { samples, day in
			let date = Calendar.current.date(byAdding: .day, value: -day, to: today)!
			let value = self.context.fakeValueGenerator(day)
			let sample = self.buildSample(config: self.context, date: date, value: value)

			samples.append(sample)
		}

		try await self.store.save(fakeQuantitySamples)
	}
}
