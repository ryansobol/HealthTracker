import HealthKitUI
import SwiftUI

struct HealthKitAuthorizationScreenView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.hkHealthStore) private var hkHealthStore

	@Environment(StepStore.self) private var stepStore
	@Environment(WeightStore.self) private var weightStore

	@State private var areHealthKitPermissionsPresented = false

	let description = """
		This app displays your step and weight data in interactive charts.

		You can also add new step or weight data to Apple Health from this app. \
		Your data is private and secure.
		"""

	var body: some View {
		VStack(spacing: 130) {
			VStack(alignment: .leading, spacing: 10) {
				Image(.appleHealth)
					.resizable()
					.frame(width: 90, height: 90)
					.shadow(color: .gray.opacity(0.3), radius: 16)
					.padding(.bottom, 12)

				Text("Apple Health Integration")
					.font(.title2.bold())

				Text(self.description)
					.foregroundStyle(.secondary)
			}

			Button("Connect Apple Health") {
				self.areHealthKitPermissionsPresented = true
			}
			.buttonStyle(.borderedProminent)
			.tint(.pink)
		}
		.padding(30)
		.healthDataAccessRequest(
			store: self.hkHealthStore,
			shareTypes: [
				self.stepStore.healthKitService.context.quantityType,
				self.weightStore.healthKitService.context.quantityType,
			],
			readTypes: [
				self.stepStore.healthKitService.context.quantityType,
				self.weightStore.healthKitService.context.quantityType,
			],
			trigger: self.areHealthKitPermissionsPresented,
		) { result in
			Task { @MainActor in
				switch result {
				case .success:
					self.dismiss()

				case .failure:
					// FIXME: Try again
					self.dismiss()
				}
			}
		}
	}
}

#Preview {
	let hkHealthStore = HKHealthStore()

	HealthKitAuthorizationScreenView()
		.environment(StepStore(hkHealthStore: hkHealthStore))
		.environment(WeightStore(hkHealthStore: hkHealthStore))
}
