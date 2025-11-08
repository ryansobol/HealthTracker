import Charts
import SwiftUI

extension ChartContent {
	func selection(label: some View, value: some View) -> some ChartContent {
		self
			.foregroundStyle(.gray.opacity(0.3))
			.offset(y: -10)
			.annotation(
				position: .top,
				spacing: 0,
				overflowResolution: .init(
					x: .fit(to: .chart),
					y: .disabled,
				),
			) {
				VStack(alignment: .leading) {
					label
						.font(.footnote.bold())
						.foregroundStyle(.secondary)

					value
						.fontWeight(.heavy)
				}
				.padding(12)
				.background {
					RoundedRectangle(cornerRadius: 4)
						.fill(Color(.tertiarySystemBackground))
						.shadow(color: .secondary.opacity(0.1), radius: 2, x: 2, y: 2)
				}
			}
	}
}
