import Charts
import SwiftUI

struct WeightLineChart: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var rawSelectedDate: Date? = nil

	let goal = 165

	let selectedStat: HealthMetricContext

	var minValue: Double {
		return self.healthKitManager.weightDiscreteMetrics.map { $0.value }.min() ?? 0
	}

	var selectedDiscreteMetric: DiscreteMetric? {
		guard let rawSelectedDate = self.rawSelectedDate else {
			return nil
		}

		return self.healthKitManager.weightDiscreteMetrics.first { metric in
			Calendar.current.isDate(rawSelectedDate, inSameDayAs: metric.date)
		}
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
				if let selectedDiscreteMetric = self.selectedDiscreteMetric {
					RuleMark(x: .value("Selected Metric", selectedDiscreteMetric.date, unit: .day))
						.foregroundStyle(.gray.opacity(0.3))
						.offset(y: -10)
						.annotation(
							position: .top,
							spacing: 0,
							overflowResolution: .init(
								x: .fit(to: .chart),
								y: .disabled,
							),
						) {
							self.annotationView(selectedDiscreteMetric)
						}
				}

				RuleMark(y: .value("Goal", self.goal))
					.foregroundStyle(.mint)
					.lineStyle(.init(lineWidth: 1, dash: [5]))

				ForEach(self.healthKitManager.weightDiscreteMetrics) { weight in
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
			.chartXSelection(value: self.$rawSelectedDate)
			.chartYScale(domain: .automatic(includesZero: false))
			.chartXAxis {
				AxisMarks { _ in
					AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
				}
			}
			.chartYAxis {
				AxisMarks { _ in
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
				.foregroundStyle(self.selectedStat.tint)
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

	WeightLineChart(selectedStat: .weight)
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}
