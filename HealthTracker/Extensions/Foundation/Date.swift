import Foundation

extension Date {
	var weekdayInt: Int {
		return Calendar.current.component(.weekday, from: self)
	}
}
