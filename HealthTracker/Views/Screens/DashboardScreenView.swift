import Charts
import SwiftUI

struct DashboardScreenView: View {
	@Environment(StepStore.self) private var stepStore
	@Environment(WeightStore.self) private var weightStore

	@State private var selectedMetricType = MetricType.step

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					Picker("Selected Metric Type", selection: self.$selectedMetricType) {
						ForEach(MetricType.allCases) { metric in
							Text(metric.title)
						}
					}
					.pickerStyle(.segmented)

					switch self.selectedMetricType {
					case .step:
						ChartCardView(context: StepBarViewContext(metricStore: self.stepStore))

						ChartCardView(context: StepPieViewContext(metricStore: self.stepStore))

					case .weight:
						ChartCardView(context: WeightLineViewContext(metricStore: self.weightStore))

						ChartCardView(context: WeightBarViewContext(metricStore: self.weightStore))
					}
				}
			}
			.padding()
			.navigationTitle("Dashboard")
			.navigationDestination(for: MetricType.self) { metric in
				DiscreteMetricScreenView(metricType: metric)
			}
		}
		.tint(self.selectedMetricType.color)
	}
}

#Preview {
	DashboardScreenView()
		.metricStoreLoader()
}
