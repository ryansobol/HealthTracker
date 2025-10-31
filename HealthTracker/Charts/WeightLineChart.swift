import Charts
import SwiftUI

struct WeightLineChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	let goal = 165

	let selectedStat: HealthMetricContext

	var minValue: Double {
		return self.healthKitManager.weightData.map {$0.value }.min() ?? 0
	}

	var body: some View {
		VStack {
			NavigationLink(value: self.selectedStat) {
				HStack {
					VStack(alignment: .leading) {
						Label("Weight", systemImage: "figure")
							.font(.title3.bold())
							.foregroundStyle(self.selectedStat.tint)

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
				RuleMark(y: .value("Goal", self.goal))
					.foregroundStyle(.mint)
					.lineStyle(.init(lineWidth: 1, dash: [5]))

				ForEach(self.healthKitManager.weightData) { weight in
					AreaMark(
						x: .value("Day", weight.date, unit: .day),
						yStart: .value("Value", weight.value),
						yEnd: .value("Min value", self.minValue),
					)
					.foregroundStyle(Gradient(colors: [self.selectedStat.tint.opacity(0.5), .clear]))

					LineMark(
						x: .value("Day", weight.date, unit: .day),
						y: .value("Value", weight.value),
					)
					.foregroundStyle(self.selectedStat.tint)
					.symbol(.circle)
				}
				.interpolationMethod(.catmullRom)
			}
			.frame(height: 150)
			.chartYScale(domain: .automatic(includesZero: false))
			.chartXAxis {
				AxisMarks { _ in
					AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
				}
			}
			.chartYAxis {
				AxisMarks { value in
					AxisGridLine()
						.foregroundStyle(.gray.opacity(0.3))

					AxisValueLabel()
				}
			}
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

	WeightLineChart(selectedStat: .weight)
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
