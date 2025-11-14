import Foundation

extension FormatStyle where Self == FloatingPointFormatStyle<Double> {
	static var step: Self {
		return .number.precision(.fractionLength(0))
	}

	static var weight: Self {
		return .number.precision(.fractionLength(1))
	}

	static var weightChange: Self {
		return .number.precision(.fractionLength(2))
	}
}

extension FormatStyle where Self == Date.FormatStyle {
	static var monthDay: Self {
		return .dateTime.month(.wide).day()
	}

	static var monthDayDigits: Self {
		return .dateTime.month(.defaultDigits).day()
	}
}
