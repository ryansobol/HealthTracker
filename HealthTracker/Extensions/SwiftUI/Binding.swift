import OrderedCollections
import SwiftUI

extension Binding where Value == Bool {
	init(optionalValue: Binding<(some Any)?>) {
		self.init(
			get: { optionalValue.wrappedValue != nil },
			set: { if !$0 { optionalValue.wrappedValue = nil }},
		)
	}
}

extension Binding where Value == Date? {
	static func selectingDate(
		from selectedDiscreteMetric: Binding<DiscreteMetric?>,
		in metricStore: some MetricStorable,
	) -> Binding<Value> {
		return Self(
			get: { selectedDiscreteMetric.wrappedValue?.date },
			set: { newValue in
				selectedDiscreteMetric.wrappedValue = newValue.flatMap { date in
					let normalizedDate = Calendar.current.startOfDay(for: date)

					return metricStore.discreteMetricByDate[normalizedDate]
				}
			},
		)
	}
}

extension Binding where Value == Double? {
	static func selectingCumulativeValue(
		from selectedAverageMetric: Binding<AverageMetric?>,
		in metricStore: some MetricStorable,
	) -> Binding<Value> {
		return Self(
			get: { selectedAverageMetric.wrappedValue?.value },
			set: { newValue in
				selectedAverageMetric.wrappedValue = newValue.flatMap { value in
					metricStore.averageMetricByWeekday.values
						.first(into: 0.0) { cummulativeValue, averageMetric in
							cummulativeValue += averageMetric.value

							return value <= cummulativeValue
						}
				}
			},
		)
	}
}

extension Binding where Value == Weekday? {
	static func selectingWeekday(
		from selectedAverageMetric: Binding<AverageMetric?>,
		in metricStore: some MetricStorable,
	) -> Binding<Value> {
		return Binding(
			get: { selectedAverageMetric.wrappedValue?.weekday },
			set: { newValue in
				selectedAverageMetric.wrappedValue = newValue.flatMap { weekday in
					return metricStore.averageMetricByWeekday[weekday]
				}
			},
		)
	}
}
