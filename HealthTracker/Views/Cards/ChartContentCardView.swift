import SwiftUI

struct ChartContentCardView<Context: ChartViewContextual, Content: View>: View {
	let context: Context

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
	ChartContentCardView(context: StepBarViewContext(metricStore: StepStore())) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}

#Preview("Without Navigation") {
	ChartContentCardView(context: StepPieViewContext(metricStore: StepStore())) {
		Rectangle()
			.frame(height: 240)
			.foregroundColor(.gray)
	}
}
