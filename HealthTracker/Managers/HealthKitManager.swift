import HealthKit
import Observation

@Observable
final class HealthKitManager {
	let store = HKHealthStore()
	let types = Set([HKQuantityType(.stepCount), HKQuantityType(.bodyMass)])

	var stepDiscreteMetrics = [DiscreteMetric]()
	var weightDiscreteMetrics = [DiscreteMetric]()

	var stepAverageMetrics = [AverageMetric]()
	var weightAverageDiffMetrics = [AverageMetric]()

	var averageStepCount: Double {
		guard !self.stepDiscreteMetrics.isEmpty else {
			return 0
		}

		return self.stepDiscreteMetrics.reduce(0) { $0 + $1.value } / Double(self.stepDiscreteMetrics.count)
	}

	var averageWeightDifference: Double {
		guard !self.weightAverageDiffMetrics.isEmpty else {
			return 0
		}

		return self.weightAverageDiffMetrics
			.reduce(0) { $0 + $1.value } / Double(self.weightAverageDiffMetrics.count)
	}

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

	// MARK: - Fetch Metrics

	func fetchMetrics() async throws -> Void {
		try await self.fetchStepMetrics()
		try await self.fetchWeightMetrics()
	}

	func fetchStepMetrics() async throws -> Void {
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

		self.stepDiscreteMetrics = statisticsCollection.statistics().map { statistic in
			.init(
				date: statistic.startDate,
				value: statistic.sumQuantity()?.doubleValue(for: .count()) ?? 0,
			)
		}

		self.stepAverageMetrics = AverageMetric.calculate(from: self.stepDiscreteMetrics)
	}

	func fetchWeightMetrics() async throws -> Void {
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

		self.weightDiscreteMetrics = statisticsCollection.statistics().map { statistic in
			.init(
				date: statistic.startDate,
				value: statistic.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0,
			)
		}

		self.weightAverageDiffMetrics = AverageMetric.calculateDifferences(from: self.weightDiscreteMetrics)
	}

	// MARK: - Create Samples

	func createSample(for metric: HealthMetricContext, date: Date, value: Double) async throws -> Void {
		switch metric {
		case .steps:
			try await self.createStepSample(
				date: date,
				value: value,
			)

			try await self.fetchStepMetrics()

		case .weight:
			try await self.createWeightSample(
				date: date,
				value: value,
			)

			try await self.fetchWeightMetrics()
		}
	}

	func createStepSample(date: Date, value: Double) async throws -> Void {
		let sample = HKQuantitySample(
			type: HKQuantityType(.stepCount),
			quantity: HKQuantity(unit: .count(), doubleValue: value),
			start: date,
			end: date,
		)

		try await self.store.save(sample)
	}

	func createWeightSample(date: Date, value: Double) async throws -> Void {
		let sample = HKQuantitySample(
			type: HKQuantityType(.bodyMass),
			quantity: HKQuantity(
				unit: .pound(),
				doubleValue: value,
			),
			start: date,
			end: date,
		)

		try await self.store.save(sample)
	}

	func createFakeSamples() async throws -> Void {
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

		print("--> Fake discrete metrics added to simulator")
	}
}
