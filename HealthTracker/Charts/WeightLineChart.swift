import Charts
import SwiftUI

struct WeightLineChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	let selectedStat: HealthMetricContext

	var body: some View {
		VStack {
			NavigationLink(value: self.selectedStat) {
				HStack {
					VStack(alignment: .leading) {
						Label("Weight", systemImage: "figure")
							.font(.title3.bold())
							.foregroundStyle(.indigo)

						Text("Avg: 180 lbs")
							.font(.caption)
					}

					Spacer()

					Image(systemName: "chevron.right")
				}
			}
			.foregroundStyle(.secondary)
			.padding(.bottom, 12)

			Chart {
				ForEach(self.healthKitManager.weightData) { weight in
					AreaMark(
						x: .value("Day", weight.date, unit: .day),
						y: .value("Value", weight.value),
					)
					.foregroundStyle(Gradient(colors: [.blue.opacity(0.5), .clear]))

					LineMark(
						x: .value("Day", weight.date, unit: .day),
						y: .value("Value", weight.value),
					)
				}
			}
			.frame(height: 150)
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightLineChart(selectedStat: .steps)
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
