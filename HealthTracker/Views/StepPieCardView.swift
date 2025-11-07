import OrderedCollections
import SwiftUI

struct StepPieCardView: View {
	@Environment(MetricStore.self) private var metricStore

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
				if self.metricStore.stepDiscreteMetricByDate.isEmpty {
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
	@Previewable @State var metricStore = MetricStore()

	StepPieCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepPieCardView()
		.environment(metricStore)
}
