import SwiftUI

struct ChartCardView<Content: View>: View {
	let chartContext: ChartContext

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
		if self.chartContext.hasNavigation {
			NavigationLink(value: self.chartContext.metricType) {
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
			Label(self.chartContext.title, systemImage: self.chartContext.symbol)
				.font(.title3.bold())
				.foregroundStyle(self.chartContext.metricType.color)

			Text(self.chartContext.subtitle)
				.font(.caption)
		}
	}
}

#Preview("With Navigation") {
	ChartCardView(chartContext: .stepBar(averageSteps: 10000)) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}

#Preview("Without Navigation") {
	ChartCardView(chartContext: .stepPie) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}
