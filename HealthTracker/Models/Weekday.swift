import Charts
import Foundation

enum Weekday: Int, CaseIterable {
	case sunday = 1
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
}

extension Weekday: CustomStringConvertible {
	var description: String {
		let formatter = DateFormatter()

		formatter.locale = Locale.current

		return formatter.weekdaySymbols[self.rawValue - 1]
	}

	var symbol: String {
		return String(describing: self)
	}

	var shortSymbol: String {
		let formatter = DateFormatter()

		formatter.locale = Locale.current

		return formatter.shortWeekdaySymbols[self.rawValue - 1]
	}
}

extension Weekday: Comparable {
	static func < (lhs: Weekday, rhs: Weekday) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}

extension Weekday: Plottable {
	var primitivePlottable: String {
		return String(describing: self)
	}

	init?(primitivePlottable: String) {
		let formatter = DateFormatter()

		formatter.locale = Locale.current

		for weekday in Weekday.allCases {
			if formatter.weekdaySymbols[weekday.rawValue - 1] == primitivePlottable {
				self = weekday
				return
			}
		}

		return nil
	}
}
