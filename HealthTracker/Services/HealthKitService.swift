import HealthKit

struct HealthKitService {
	// MARK: - Configuration

	private struct Configuration {
		let quantityType: HKQuantityType
		let unit: HKUnit
		let statisticsOptions: HKStatisticsOptions
		let fakeValueGenerator: (Int) -> Double

		static let steps = Configuration(
			quantityType: HKQuantityType(.stepCount),
			unit: .count(),
			statisticsOptions: .cumulativeSum,
			fakeValueGenerator: { _ in .random(in: 4000 ... 20000) },
		)

		static let weight = Configuration(
			quantityType: HKQuantityType(.bodyMass),
			unit: .pound(),
			statisticsOptions: .mostRecent,
			fakeValueGenerator: { day in .random(in: 160 + Double(day / 3) ... 165 + Double(day / 3)) },
		)
	}

	// MARK: - Properties

	private let configurations: [MetricType: Configuration] = [
		.steps: .steps,
		.weight: .weight,
	]

	let store = HKHealthStore()
	let types: Set<HKQuantityType>

	init() {
		self.types = Set(self.configurations.values.map { $0.quantityType })
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
		guard let config = self.configurations[metricType] else {
			fatalError("No configuration for metric type: \(metricType)")
		}

		guard try await self.isAuthorizationRequestUnnecessary(for: config.quantityType) else {
			throw AuthorizationRequestNecessaryError(metricType: metricType)
		}

		let fromDate = Date.now

		guard let dateInterval = DateInterval(from: fromDate, daysAgo: daysAgo) else {
			fatalError("No date interval from \(fromDate) to \(daysAgo) days ago")
		}

		let queryPredicate = HKQuery.predicateForSamples(
			withStart: dateInterval.start,
			end: dateInterval.end,
		)

		let samplePredicate = HKSamplePredicate.quantitySample(
			type: config.quantityType,
			predicate: queryPredicate,
		)

		let statisticsCollectionQuery = HKStatisticsCollectionQueryDescriptor(
			predicate: samplePredicate,
			options: config.statisticsOptions,
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
		guard let config = self.configurations[metricType] else {
			fatalError("No configuration for metric type: \(metricType)")
		}

		guard self.isSharingAuthorized(for: config.quantityType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let sample = self.buildSample(config: config, date: date, value: value)

		try await self.store.save(sample)
	}

	private func buildSample(config: Configuration, date: Date, value: Double) -> HKQuantitySample {
		let quantity = HKQuantity(unit: config.unit, doubleValue: value)

		return HKQuantitySample(
			type: config.quantityType,
			quantity: quantity,
			start: date,
			end: date,
		)
	}

	// MARK: - Fake Data Creation

	func createFakeSamples(daysAgo: Int) async throws {
		let today = Date.now

		let configsSamples = try configurations.flatMap { metricType, config in
			guard self.isSharingAuthorized(for: config.quantityType) else {
				throw AppError.sharingNotAuthorized(metricType: metricType)
			}

			var configSamples = [HKQuantitySample]()

			configSamples.reserveCapacity(daysAgo)

			return (0 ..< daysAgo).reduce(into: configSamples) { samples, day in
				let date = Calendar.current.date(byAdding: .day, value: -day, to: today)!
				let value = config.fakeValueGenerator(day)
				let sample = self.buildSample(config: config, date: date, value: value)

				samples.append(sample)
			}
		}

		try await self.store.save(configsSamples)
	}
}
