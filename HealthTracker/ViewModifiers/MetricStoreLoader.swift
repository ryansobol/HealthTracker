import HealthKit
import OSLog
import SwiftUI

struct MetricStoreLoader: ViewModifier {
	private let logger = Logger(category: Self.self)

	@Environment(\.scenePhase) private var scenePhase

	@State private var appError: AppError? = nil
	@State private var isPresentedHealthKitAuthorization = false

	@State private var stepStore: StepStore
	@State private var weightStore: WeightStore

	init() {
		let hkHealthStore = HKHealthStore()

		self._stepStore = State(initialValue: StepStore(hkHealthStore: hkHealthStore))
		self._weightStore = State(initialValue: WeightStore(hkHealthStore: hkHealthStore))
	}

	func body(content: Content) -> some View {
		content
			.fullScreenCover(
				isPresented: self.$isPresentedHealthKitAuthorization,
				onDismiss: self.onDismissHealthKitAuthorization,
			) {
				HealthKitAuthorizationScreenView()
			}
			.alert(for: self.$appError)
			.onChange(of: self.scenePhase) { oldValue, newValue in
				guard newValue == .active && oldValue != .active else {
					return
				}

				self.onActiveScene()
			}
			.environment(\.requestHealthKitAuthorization, self.requestHealthKitAuthorization)
			.environment(self.stepStore)
			.environment(self.weightStore)
	}

	private func createFakeMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.stepStore.createFakeMetrics() }
			group.addTask { try await self.weightStore.createFakeMetrics() }

			try await group.waitForAll()
		}
	}

	private func fetchMetrics() async throws -> Void {
		try await withThrowingTaskGroup { group in
			group.addTask { try await self.stepStore.fetchMetrics() }
			group.addTask { try await self.weightStore.fetchMetrics() }

			try await group.waitForAll()
		}
	}

	private func onActiveScene() -> Void {
		Task {
			do {
				try await self.fetchMetrics()
			}
			catch is AuthorizationRequestNecessaryError {
				self.isPresentedHealthKitAuthorization = true
			}
			catch let error as AppError {
				self.logger.error(for: error)

				self.appError = error
			}
			catch {
				let error = AppError.caught(underlyingError: error)

				self.logger.error(for: error)

				self.appError = error
			}
		}
	}

	private func onDismissHealthKitAuthorization() -> Void {
		Task {
			do {
				#if targetEnvironment(simulator)
					try await self.createFakeMetrics()
				#endif

				try await self.fetchMetrics()
			}
			catch {
				self.logger.error("\(error)")
			}
		}
	}

	private func requestHealthKitAuthorization() -> Void {
		self.isPresentedHealthKitAuthorization = true
	}
}
