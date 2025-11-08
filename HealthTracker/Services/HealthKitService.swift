import HealthKit

struct HealthKitService {
	// MARK: - Configuration

	private struct Configuration {
		let quantityType: HKQuantityType
		let unit: HKUnit
		let statisticsOptions: HKStatisticsOptions

		static let steps = Configuration(
			quantityType: HKQuantityType(.stepCount),
			unit: .count(),
			statisticsOptions: .cumulativeSum,
		)

		static let weight = Configuration(
			quantityType: HKQuantityType(.bodyMass),
			unit: .pound(),
			statisticsOptions: .mostRecent,
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
	func fetchStepStatistics() async throws -> [HKStatistics] {
		return try await self.fetchStatistics(for: .steps)
	}

	@concurrent
	func fetchWeightStatistics() async throws -> [HKStatistics] {
		return try await self.fetchStatistics(for: .weight)
	}

	private func fetchStatistics(for metricType: MetricType) async throws -> [HKStatistics] {
		guard let config = self.configurations[metricType] else {
			fatalError("No configuration for metric type: \(metricType)")
		}

		guard try await self.isAuthorizationRequestUnnecessary(for: config.quantityType) else {
			throw AuthorizationRequestNecessaryError(metricType: metricType)
		}

		let fromDate = Date.now
		let daysAgo = 28

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

	private func createSample(metricType: MetricType, date: Date, value: Double) async throws {
		guard let config = self.configurations[metricType] else {
			fatalError("No configuration for metric type: \(metricType)")
		}

		guard self.isSharingAuthorized(for: config.quantityType) else {
			throw AppError.sharingNotAuthorized(metricType: metricType)
		}

		let quantity = HKQuantity(unit: config.unit, doubleValue: value)

		let sample = HKQuantitySample(
			type: config.quantityType,
			quantity: quantity,
			start: date,
			end: date,
		)

		try await self.store.save(sample)
	}

	// MARK: - Fake Data Creation

	func createFakeSamples() async throws -> Void {
		for (metricType, config) in self.configurations {
			guard self.isSharingAuthorized(for: config.quantityType) else {
				throw AppError.sharingNotAuthorized(metricType: metricType)
			}
		}

		let days = 28
		var fakeSamples = [HKQuantitySample]()

		fakeSamples.reserveCapacity(days * 2)

		for i in 0 ..< days {
			let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
			let endDate = Calendar.current.date(byAdding: .second, value: i, to: startDate)!

			let stepConfig = self.configurations[.steps]!

			let stepQuantity = HKQuantity(
				unit: .count(),
				doubleValue: .random(in: 4000 ... 20000),
			)

			let stepSample = HKQuantitySample(
				type: stepConfig.quantityType,
				quantity: stepQuantity,
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(stepSample)

			let weightConfig = self.configurations[.weight]!

			let weightQuantity = HKQuantity(
				unit: .pound(),
				doubleValue: .random(in: 160 + Double(i / 3) ... 165 + Double(i / 3)),
			)

			let weightSample = HKQuantitySample(
				type: weightConfig.quantityType,
				quantity: weightQuantity,
				start: startDate,
				end: endDate,
			)

			fakeSamples.append(weightSample)
		}

		try! await self.store.save(fakeSamples)
	}
}
