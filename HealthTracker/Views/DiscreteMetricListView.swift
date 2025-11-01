import SwiftUI

struct DiscreteMetricListView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var newDate = Date.now
	@State private var newValue = ""
	@State private var isPresentingForm = false

	let metricType: MetricType

	var discreteMetrics: [DiscreteMetric] {
		return switch self.metricType {
		case .steps: self.healthKitManager.stepDiscreteMetrics
		case .weight: self.healthKitManager.weightDiscreteMetrics
		}
	}

	var body: some View {
		List(self.discreteMetrics.reversed()) { healthMetric in
			HStack {
				Text(healthMetric.date, format: .dateTime.month().day().year())

				Spacer()

				Text(
					healthMetric.value,
					format: .number.precision(.fractionLength(self.metricType == .steps ? 0 : 1)),
				)
			}
		}
		.navigationTitle(self.metricType.title)
		.sheet(isPresented: self.$isPresentingForm) {
			self.addDataView
		}
		.toolbar {
			Button("Add Data", systemImage: "plus") {
				self.isPresentingForm = true
			}
		}
	}

	var addDataView: some View {
		NavigationStack {
			Form {
				DatePicker("Data", selection: self.$newDate, displayedComponents: .date)

				HStack {
					Text(self.metricType.title)

					Spacer()

					TextField("Value", text: self.$newValue)
						.multilineTextAlignment(.trailing)
						.frame(width: 140)
						.keyboardType(self.metricType == .steps ? .numberPad : .decimalPad)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(self.metricType.title)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Dismiss") {
						self.isPresentingForm = false
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Add Data") {
						Task {
							do {
								try await self.healthKitManager.createSample(
									metricType: self.metricType,
									date: self.newDate,
									// TODO: Add validation
									value: Double(self.newValue)!,
								)
							}
							catch {
								print(error)
							}

							self.isPresentingForm = false
						}
					}
				}
			}
		}
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	NavigationStack {
		DiscreteMetricListView(metricType: .weight)
	}
	.task {
		try! await healthKitManager.fetchMetrics()
	}
	.environment(healthKitManager)
}
