import Charts
import SwiftUI

struct StepPieChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var rawSelectedChartValue: Double? = 0

	var selectedWeekday: WeekdayChartData? {
		guard let rawSelectedChartValue = self.rawSelectedChartValue else {
			return nil
		}

		var total = 0.0

		return ChartMath.averageWeekdayCount(for: self.healthKitManager.stepData).first { weekday in
			total += weekday.value

			return rawSelectedChartValue <= total
		}
	}

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
						outerRadius: self.selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 140 : 110,
						angularInset: 1,
					)
					.foregroundStyle(.pink.gradient)
					.cornerRadius(6)
					.opacity(self.selectedWeekday?.date.weekdayInt == weekday.date.weekdayInt ? 1 : 0.3)
				}
			}
			.frame(height: 240)
			.chartAngleSelection(value: self.$rawSelectedChartValue.animation(.smooth(duration: 0.25)))
			.chartBackground { _ in
				if let selectedWeekday = self.selectedWeekday {
					VStack {
						Text(selectedWeekday.date.weekdayTitle)
							.font(.title2.bold())
							.animation(.none, value: selectedWeekday.date.weekdayTitle)

						Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
							.fontWeight(.medium)
							.foregroundStyle(.secondary)
							.contentTransition(.numericText())
					}
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

	StepPieChart()
		.task {
			try! await healthKitManager.fetchData()
		}
		.environment(healthKitManager)
}
