import SwiftUI

enum HealthMetricContext: CaseIterable, Identifiable {
	case steps
	case weight

	var id: Self {
		return self
	}

	var title: String {
		return switch self {
		case .steps: "Steps"
		case .weight: "Weight"
		}
	}

	var tint: Color {
		return switch self {
		case .steps: .pink
		case .weight: .indigo
		}
	}
}

struct ContentView: View {
	@State private var selectedStat = HealthMetricContext.steps

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					Picker("Selected Stat", selection: self.$selectedStat) {
						ForEach(HealthMetricContext.allCases) { metric in
							Text(metric.title)
						}
					}
					.pickerStyle(.segmented)

					VStack {
						NavigationLink(value: self.selectedStat) {
							HStack {
								VStack(alignment: .leading) {
									Label("Steps", systemImage: "figure.walk")
										.font(.title3.bold())
										.foregroundStyle(.pink)

									Text("Avg: 10K steps")
										.font(.caption)
								}

								Spacer()

								Image(systemName: "chevron.right")
							}
						}
						.foregroundStyle(.secondary)
						.padding(.bottom, 12)

						RoundedRectangle(cornerRadius: 12)
							.foregroundStyle(.secondary)
							.frame(height: 150)
					}
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color(.secondarySystemBackground))
					}

					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							Label("Averages", systemImage: "calendar")
								.font(.title3.bold())
								.foregroundStyle(.pink)

							Text("Last 28 Days")
								.font(.caption)
								.foregroundStyle(.secondary)
						}

						RoundedRectangle(cornerRadius: 12)
							.foregroundStyle(.secondary)
							.frame(height: 240)
					}
					.padding()
					.background {
						RoundedRectangle(cornerRadius: 12)
							.fill(Color(.secondarySystemBackground))
					}
				}
			}
			.padding()
			.navigationTitle("Dashboard")
			.navigationDestination(for: HealthMetricContext.self) { metric in
				Text(metric.title)
			}
		}
		.tint(self.selectedStat.tint)
	}
}

#Preview {
	ContentView()
}
