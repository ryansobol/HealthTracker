import OrderedCollections
import OSLog
import SwiftUI

struct DiscreteMetricListView: View {
	private let logger = Logger(category: Self.self)

	@Environment(HealthKitManager.self) private var healthKitManager

	@State private var appError: AppError? = nil
	@State private var newDate = Date.now
	@State private var newValue = ""
	@State private var isAddDataFormPresented = false

	let metricType: MetricType

	@Binding var isHealthKitAuthorizationPresented: Bool

	var discreteMetrics: OrderedDictionary<Date, DiscreteMetric>.Values {
		return switch self.metricType {
		case .steps: self.healthKitManager.stepDiscreteMetricByDate.values
		case .weight: self.healthKitManager.weightDiscreteMetricByDate.values
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
		.alert(for: self.$appError)
		.sheet(isPresented: self.$isAddDataFormPresented) {
			self.addDataView
		}
		.toolbar {
			Button("Add Data", systemImage: "plus") {
				self.isAddDataFormPresented = true
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
						self.isAddDataFormPresented = false
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Add Data") {
						Task {
							do {
								try await self.healthKitManager.createSample(
									metricType: self.metricType,
									date: self.newDate,
									value: self.validateNewValue(),
								)
							}
							catch is AuthorizationRequestNecessaryError {
								self.isHealthKitAuthorizationPresented = true
							}
							catch let error as AppError {
								self.logger.error(for: error)

								self.appError = error
							}
							catch {
								let error = AppError.caught(underlyingError: error)

								self.logger.error(for: error)

								self.appError = error
							}

							self.isAddDataFormPresented = false
							self.newValue = ""
						}
					}
					.disabled(self.isAddDataButtonDisabled)
				}
			}
		}
	}

	private var isAddDataButtonDisabled: Bool {
		return (try? self.validateNewValue()) == nil
	}

	private func validateNewValue() throws -> Double {
		guard let value = Double(self.newValue), value > 0 else {
			throw AppError.invalidMetricValue(metricType: self.metricType, value: self.newValue)
		}

		return value
	}
}

#Preview {
	@Previewable @State var healthKitManager = HealthKitManager()

	NavigationStack {
		DiscreteMetricListView(
			metricType: .weight,
			isHealthKitAuthorizationPresented: .constant(false),
		)
	}
	.task {
		try! await healthKitManager.fetchMetrics()
	}
	.environment(healthKitManager)
}
