import OrderedCollections
import SwiftUI

struct StepBarCardView: View {
	let chartType = ChartType.stepBar

	@Environment(MetricStore.self) private var metricStore

	var body: some View {
		ChartCardView(chartType: self.chartType) {
			Group {
				if self.metricStore.stepDiscreteMetricByDate.isEmpty {
					EmptyChart(
						title: "No Data",
						systemName: "chart.bar",
						description: "No steps data collected from HealthKit",
					)
				}
				else {
					StepBarChart(chartType: self.chartType)
				}
			}
			.frame(height: 150)
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

			Text(selectedDiscreteMetric.value, format: .number.precision(.fractionLength(0)))
				.fontWeight(.heavy)
				.foregroundStyle(self.chartType.metricType.tint)
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
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.task {
			try! await metricStore.fetchMetrics()
		}
		.environment(metricStore)
}

#Preview("Without Metrics") {
	@Previewable @State var metricStore = MetricStore()

	StepBarCardView()
		.environment(metricStore)
}
