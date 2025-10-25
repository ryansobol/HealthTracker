import Charts
import SwiftUI

struct StepPieChart: View {
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

			Chart {
				ForEach(ChartMath.averageWeekdayCount(for: self.healthKitManager.stepData)) { weekday in
					SectorMark(
						angle: .value("Average Steps", weekday.value),
						innerRadius: .ratio(0.618),
						angularInset: 1,
					)
					.foregroundStyle(.pink.gradient)
					.cornerRadius(6)
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

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	StepPieChart()
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
