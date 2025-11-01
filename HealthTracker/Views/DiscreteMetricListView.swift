import SwiftUI

struct DiscreteMetricListView: View {
	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var newDate = Date.now
	@State private var newValue = ""
	@State private var isPresentingForm = false

	let metric: HealthMetricContext

	var discreteMetrics: [DiscreteMetric] {
		return switch self.metric {
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
					format: .number.precision(.fractionLength(self.metric == .steps ? 0 : 1)),
				)
			}
		}
		.navigationTitle(self.metric.title)
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
					Text(self.metric.title)

					Spacer()

					TextField("Value", text: self.$newValue)
						.multilineTextAlignment(.trailing)
						.frame(width: 140)
						.keyboardType(self.metric == .steps ? .numberPad : .decimalPad)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.navigationTitle(self.metric.title)
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
									for: self.metric,
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
		DiscreteMetricListView(metric: .weight)
	}
	.task {
		try! await healthKitManager.fetchMetrics()
	}
	.environment(healthKitManager)
}
