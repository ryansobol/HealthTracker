import SwiftUI

struct ChartContentCardView<Content: View>: View {
	let context: ChartContext

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
		if self.context.hasNavigation {
			NavigationLink(value: self.context.metricType) {
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
			Label(self.context.title, systemImage: self.context.symbolTitle)
				.font(.title3.bold())
				.foregroundStyle(self.context.metricType.color)

			Text(self.context.subtitle)
				.font(.caption)
		}
	}
}

#Preview("With Navigation") {
	@Previewable @State var metricStore = MetricStore()

	ChartContentCardView(context: .stepBar(store: metricStore)) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}

#Preview("Without Navigation") {
	@Previewable @State var metricStore = MetricStore()

	ChartContentCardView(context: .stepPie(store: metricStore)) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}
