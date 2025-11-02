import SwiftUI

struct StepPieCardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	var body: some View {
		VStack(alignment: .leading) {
			VStack(alignment: .leading) {
				Label("Averages", systemImage: "calendar")
					.font(.title3.bold())
					.foregroundStyle(.pink)

				Text("Last 28 Days")
					.font(.caption)
					.foregroundStyle(.secondary)
			}

			Group {
				if self.healthKitManager.stepDiscreteMetrics.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.pie",
						description: "No steps data collected from HealthKit",
					)
				}
				else {
					StepPieChart()
				}
			}
			.frame(height: 240)
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var healthKitManager = HealthKitManager()

	StepPieCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}

#Preview("Without Metrics") {
	@Previewable @State var healthKitManager = HealthKitManager()

	StepPieCardView()
		.environment(healthKitManager)
}
