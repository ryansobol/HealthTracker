import SwiftUI

struct WeightBarCardView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	let metricType = MetricType.weight

	var body: some View {
		VStack {
			HStack {
				VStack(alignment: .leading) {
					Label("Average Change", systemImage: "figure")
						.font(.title3.bold())
						.foregroundStyle(self.metricType.tint)

					Text("Last 28 Days")
						.font(.caption)
				}

				Spacer()
			}
			.foregroundStyle(.secondary)
			.padding(.bottom, 12)

			WeightBarChart()
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}

	func annotationView(_ selectedAverageMetric: AverageMetric) -> some View {
		VStack(alignment: .leading) {
			Text(selectedAverageMetric.weekday.symbol)
				.font(.footnote.bold())
				.foregroundStyle(.secondary)

			Text(selectedAverageMetric.value, format: .number.precision(.fractionLength(2)))
				.fontWeight(.heavy)
				.foregroundStyle(selectedAverageMetric.value >= 0 ? self.metricType.tint : Color.mint)
		}
		.padding(12)
		.background {
			RoundedRectangle(cornerRadius: 4)
				.fill(Color(.secondarySystemBackground))
				.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
		}
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightBarCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}
