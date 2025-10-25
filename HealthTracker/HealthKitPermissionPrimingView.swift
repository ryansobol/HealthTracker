import HealthKitUI
import SwiftUI

struct HealthKitPermissionPrimingView: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var isShowingHealthKitPermissions = false

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
				self.isShowingHealthKitPermissions = true
			}
			.buttonStyle(.borderedProminent)
			.tint(.pink)
		}
		.padding(30)
		.healthDataAccessRequest(
			store: self.healthKitManager.store,
			shareTypes: self.healthKitManager.types,
			readTypes: self.healthKitManager.types,
			trigger: self.isShowingHealthKitPermissions,
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
	HealthKitPermissionPrimingView()
		.environment(HealthKitManager())
}
