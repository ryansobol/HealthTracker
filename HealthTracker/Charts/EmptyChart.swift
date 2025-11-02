import SwiftUI

struct EmptyChart: View {
	let title: String
	let systemName: String
	let description: String

	var body: some View {
		ContentUnavailableView {
			Image(systemName: self.systemName)
				.font(.largeTitle)
				.foregroundStyle(.secondary)
				.padding(.bottom, 4)

			Text(self.title)
				.font(.callout.bold())

			Text(self.description)
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
	}
}

#Preview {
	EmptyChart(
		title: "No Data",
		systemName: "chart.bar",
		description: "No steps collected from HealthKit",
	)
}
