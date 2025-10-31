import Foundation

enum Weekday: Int {
	case sunday = 0
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

		return formatter.weekdaySymbols[self.rawValue]
	}
}

extension Weekday: Comparable {
	static func < (lhs: Weekday, rhs: Weekday) -> Bool {
		return lhs.rawValue < rhs.rawValue
	}
}
