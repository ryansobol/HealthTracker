import HealthKit
import Observation
import OSLog

private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "HealthKitManager")

@Observable
final class HealthKitManager {
	let store = HKHealthStore()

	var stepDiscreteMetrics = [DiscreteMetric]()
	var weightDiscreteMetrics = [DiscreteMetric]()

	var stepAverageMetrics = [AverageMetric]()
	var weightAverageDiffMetrics = [AverageMetric]()

	let types: Set<HKQuantityType>

	private let stepType = HKQuantityType(.stepCount)
	private let weightType = HKQuantityType(.bodyMass)

	init() {
		self.types = Set([
			self.stepType,
			self.weightType,
		])
	}

	var averageStepCount: Double {
		guard !self.stepDiscreteMetrics.isEmpty else {
			return 0
		}

		return self.stepDiscreteMetrics
			.reduce(0) { $0 + $1.value } / Double(self.stepDiscreteMetrics.count)
	}

	var averageWeightDifference: Double {
		guard !self.weightAverageDiffMetrics.isEmpty else {
			return 0
		}

		return self.weightAverageDiffMetrics
			.reduce(0) { $0 + $1.value } / Double(self.weightAverageDiffMetrics.count)
	}

	private func isAuthorizationRequestUnnecessary(for type: HKQuantityType) async throws -> Bool {
		let result = try await self.store.statusForAuthorizationRequest(
			toShare: Set([type]),
			read: Set([type]),
		)

		return result == .unnecessary
	}

	// MARK: - Fetch Metrics

	func fetchMetrics() async throws -> Void {
		try await self.fetchStepMetrics()
		try await self.fetchWeightMetrics()
	}

	private func fetchStepMetrics() async throws -> Void {
		guard try await self.isAuthorizationRequestUnnecessary(for: self.stepType) else {
			throw AuthorizationError.authorizationRequestNecessary(metricType: .steps)
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

		self.stepDiscreteMetrics = statisticsCollection.statistics().map { statistic in
			.init(
				date: statistic.startDate,
				value: statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0,
			)
		}

		self.stepAverageMetrics = AverageMetric.calculate(from: self.stepDiscreteMetrics)
	}

	private func fetchWeightMetrics() async throws -> Void {
		guard try await self.isAuthorizationRequestUnnecessary(for: self.weightType) else {
			throw AuthorizationError.authorizationRequestNecessary(metricType: .weight)
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

		self.weightDiscreteMetrics = statisticsCollection.statistics().map { statistic in
			.init(
				date: statistic.startDate,
				value: statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0,
			)
		}

		self.weightAverageDiffMetrics = AverageMetric.calculateDifferences(
			from: self.weightDiscreteMetrics,
		)
	}

	// MARK: - Create Samples

	func createSample(metricType: MetricType, date: Date, value: Double) async throws -> Void {
		switch metricType {
		case .steps:
			try await self.createStepSample(
				metricType: metricType,
				date: date,
				value: value,
			)

			try await self.fetchStepMetrics()

		case .weight:
			try await self.createWeightSample(
				metricType: metricType,
				date: date,
				value: value,
			)

			try await self.fetchWeightMetrics()
		}
	}

	private func createStepSample(
		metricType: MetricType,
		date: Date,
		value: Double,
	) async throws -> Void {
		guard self.store.authorizationStatus(for: self.stepType) == .sharingAuthorized else {
			throw AuthorizationError.sharingNotAuthorized(metricType: metricType)
		}

		let quantity = HKQuantity(unit: .count(), doubleValue: value)
		let sample = HKQuantitySample(type: self.stepType, quantity: quantity, start: date, end: date)

		try await self.store.save(sample)
	}

	private func createWeightSample(
		metricType: MetricType,
		date: Date,
		value: Double,
	) async throws -> Void {
		guard self.store.authorizationStatus(for: self.weightType) == .sharingAuthorized else {
			throw AuthorizationError.sharingNotAuthorized(metricType: metricType)
		}

		let quantity = HKQuantity(unit: .pound(), doubleValue: value)
		let sample = HKQuantitySample(type: self.weightType, quantity: quantity, start: date, end: date)

		try await self.store.save(sample)
	}

	func createFakeSamples() async throws -> Void {
		#if !targetEnvironment(simulator)
			return
		#endif

		guard self.store.authorizationStatus(for: self.stepType) == .sharingAuthorized else {
			throw AuthorizationError.sharingNotAuthorized(metricType: .steps)
		}

		guard self.store.authorizationStatus(for: self.weightType) == .sharingAuthorized else {
			throw AuthorizationError.sharingNotAuthorized(metricType: .weight)
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

		logger.debug("Created fake discrete samples in simulator")
	}
}
