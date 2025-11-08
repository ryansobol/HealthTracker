import SwiftUI

struct ChartCardView<Content: View>: View {
	let chartType: ChartType

	@ViewBuilder let content: () -> Content

	var body: some View {
		VStack(alignment: .leading) {
			self.header
				.foregroundStyle(.secondary)
				.padding(.bottom, 8)

			self.content()
		}
		.padding()
		.background {
			RoundedRectangle(cornerRadius: 12)
				.fill(Color(.secondarySystemBackground))
		}
	}

	@ViewBuilder
	var header: some View {
		if self.chartType.hasNavigation {
			NavigationLink(value: self.chartType.metricType) {
				HStack {
					self.titles

					Spacer()

					Image(systemName: "chevron.right")
				}
			}
		}
		else {
			self.titles
		}
	}

	var titles: some View {
		VStack(alignment: .leading) {
			Label(self.chartType.title, systemImage: self.chartType.symbol)
				.font(.title3.bold())
				.foregroundStyle(self.chartType.metricType.color)

			Text(self.chartType.subtitle)
				.font(.caption)
		}
	}
}

#Preview("With Navigation") {
	ChartCardView(chartType: .stepBar(averageSteps: 10000)) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}

#Preview("Without Navigation") {
	ChartCardView(chartType: .stepPie) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}
