import Charts
import SwiftUI

struct WeightLineChart: View {
	let goal = 165
	let metricType = MetricType.weight

	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var selectedDiscreteMetric: DiscreteMetric? = nil

	private var selectedDateBinding: Binding<Date?> {
		return Binding(
			get: { self.selectedDiscreteMetric?.date },
			set: { newValue in
				self.selectedDiscreteMetric = if let newValue {
					self.healthKitManager.weightDiscreteMetrics.first { discreteMetric in
						Calendar.current.isDate(newValue, inSameDayAs: discreteMetric.date)
					}
				}
				else {
					nil
				}
			},
		)
	}

	private func isBarMarkOpaque(for discreteMetric: DiscreteMetric) -> Bool {
		guard let selectedDiscreteMetric = self.selectedDiscreteMetric else {
			return false
		}

		return selectedDiscreteMetric.date != discreteMetric.date
	}

	var minValue: Double {
		return self.healthKitManager.weightDiscreteMetrics.map { $0.value }.min() ?? 0
	}

	var body: some View {
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
				.foregroundStyle(Gradient(colors: [self.metricType.tint.opacity(0.5), .clear]))

				LineMark(
					x: .value("Day", weight.date, unit: .day),
					y: .value("Value", weight.value),
				)
				.foregroundStyle(self.metricType.tint)
				.symbol(.circle)
			}
			.interpolationMethod(.catmullRom)
		}
		.chartXSelection(value: self.selectedDateBinding)
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
		.sensoryFeedback(.selection, trigger: self.selectedDiscreteMetric?.date)
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

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	WeightLineCardView()
		.task {
			try! await healthKitManager.fetchMetrics()
		}
		.environment(healthKitManager)
}
