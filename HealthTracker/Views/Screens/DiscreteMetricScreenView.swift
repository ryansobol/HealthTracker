import OrderedCollections
import OSLog
import SwiftUI

struct DiscreteMetricScreenView: View {
	private let logger = Logger(category: Self.self)

	@Environment(StepStore.self) private var stepStore
	@Environment(WeightStore.self) private var weightStore

	@State private var appError: AppError? = nil
	@State private var newDate = Date.now
	@State private var newValue = ""
	@State private var isAddDataFormPresented = false

	let metricType: MetricType

	@Binding var isHealthKitAuthorizationPresented: Bool

	var discreteMetrics: OrderedDictionary<Date, DiscreteMetric>.Values {
		return switch self.metricType {
		case .steps: self.stepStore.discreteMetricByDate.values
		case .weight: self.weightStore.discreteMetricByDate.values
		}
	}

	var body: some View {
		List(self.discreteMetrics.reversed()) { healthMetric in
			LabeledContent {
				Text(
					healthMetric.value,
					format: .number.precision(.fractionLength(self.metricType == .steps ? 0 : 1)),
				)
			} label: {
				Text(healthMetric.date, format: .dateTime.month().day().year())
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

				LabeledContent(self.metricType.title) {
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
					Button("Add Data", action: self.addData)
						.disabled(self.isAddDataButtonDisabled)
				}
			}
		}
	}

	private func addData() -> Void {
		Task {
			do {
				switch self.metricType {
				case .steps:
					try await self.stepStore.createMetric(
						date: self.newDate,
						value: self.validateNewValue(),
					)

					try await self.stepStore.fetchMetrics()

				case .weight:
					try await self.weightStore.createMetric(
						date: self.newDate,
						value: self.validateNewValue(),
					)

					try await self.weightStore.fetchMetrics()
				}
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
	@Previewable @State var stepStore = StepStore()
	@Previewable @State var weightStore = WeightStore()

	NavigationStack {
		DiscreteMetricScreenView(
			metricType: .weight,
			isHealthKitAuthorizationPresented: .constant(false),
		)
	}
	.task {
		try! await stepStore.fetchMetrics()
		try! await weightStore.fetchMetrics()
	}
	.environment(stepStore)
	.environment(weightStore)
}
