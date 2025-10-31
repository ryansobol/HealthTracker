import Foundation

extension Date {
	var weekday: Weekday {
		return Weekday(rawValue: Calendar.current.component(.weekday, from: self) - 1)!
	}
}
