import OSLog
import SwiftUI

struct DiscreteMetricListView: View {
	private let logger = Logger(category: Self.self)

	@Environment(HealthKitManager.self) private var healthKitManager
	@Environment(\.openURL) private var openURL

	@State private var appError: AppError? = nil
	@State private var newDate = Date.now
	@State private var newValue = ""
	@State private var isAddDataFormPresented = false

	let metricType: MetricType

	@Binding var isPermissionPrimerPresented: Bool

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
									// TODO: Add validation
									value: Double(self.newValue)!,
								)
							}
							catch is AuthorizationRequestNecessaryError {
								self.isPermissionPrimerPresented = true
							}
							catch let error as AppError {
								logger.error(error)

								self.appError = error
							}
							catch {
								let error = AppError.caught(underlyingError: error)

								self.logger.error(error)

								self.appError = error
							}

							self.isAddDataFormPresented = false
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
		DiscreteMetricListView(metricType: .weight, isPermissionPrimerPresented: .constant(false))
	}
	.task {
		try! await healthKitManager.fetchMetrics()
	}
	.environment(healthKitManager)
}
