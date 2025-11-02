import Charts
import SwiftUI

struct WeightLineCardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	let metricType = MetricType.weight

	var body: some View {
		VStack {
			NavigationLink(value: self.metricType) {
				HStack {
					VStack(alignment: .leading) {
						Label("Weight", systemImage: "figure")
							.font(.title3.bold())
							.foregroundStyle(self.metricType.tint)

						Text("Avg: 180 lbs")
							.font(.caption)
					}

					Spacer()

					Image(systemName: "chevron.right")
				}
			}
			.foregroundStyle(.secondary)
			.padding(.bottom, 12)

			Group {
				if self.healthKitManager.weightDiscreteMetrics.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.xyaxis.line",
						description: "No weight data collected from HealthKit",
					)
				}
				else {
					WeightLineChart()
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

	func annotationView(_ selectedDiscreteMetric: DiscreteMetric) -> some View {
		VStack(alignment: .leading) {
			Text(
				selectedDiscreteMetric.date,
				format: .dateTime.weekday(.abbreviated).month(.abbreviated).day(),
			)
			.font(.footnote.bold())
			.foregroundStyle(.secondary)

			Text(selectedDiscreteMetric.value, format: .number.precision(.fractionLength(1)))
				.fontWeight(.heavy)
				.foregroundStyle(self.metricType.tint)
		}
		.padding(12)
		.background {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(.secondarySystemBackground))
				.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
		}
	}
}

#Preview("With Metrics") {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightLineCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}

#Preview("Without Metrics") {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightLineCardView()
		.environment(healthKitManager)
}
