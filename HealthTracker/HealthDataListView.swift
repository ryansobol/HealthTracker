import SwiftUI

struct HealthDataListView: View {
	@State private var addDataDate = Date.now
	@State private var isShowingAddData = false
	@State private var valueToAdd = ""

	let metric: HealthMetricContext

	var body: some View {
		// Text(self.metric.title)
		List(0 ..< 28) { _ in
			HStack {
				Text(Date(), format: .dateTime.month().day().year())

				Spacer()

				Text(10000, format: .number.precision(.fractionLength(self.metric == .steps ? 0 : 1)))
			}
		}
		.navigationTitle(self.metric.title)
		.sheet(isPresented: self.$isShowingAddData) {
			self.addDataView
		}
		.toolbar {
			Button("Add Data", systemImage: "plus") {
				self.isShowingAddData = true
			}
		}
	}

	var addDataView: some View {
		NavigationStack {
			Form {
				DatePicker("Data", selection: self.$addDataDate, displayedComponents: .date)

				HStack {
					Text(self.metric.title)

					Spacer()

					TextField("Value", text: self.$valueToAdd)
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
						self.isShowingAddData = false
					}
				}

				ToolbarItem(placement: .topBarTrailing) {
					Button("Add Data") {
						// TODO:
					}
				}
			}
		}
	}
}

#Preview {
	NavigationStack {
		HealthDataListView(metric: .weight)
	}
}
