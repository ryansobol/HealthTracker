import Foundation

extension DateInterval {
	nonisolated init?(from: Date, daysAgo: Int) {
		let calendar = Calendar.current
		let startOfEndDate = calendar.startOfDay(for: from)

		guard let endDate = calendar.date(byAdding: .day, value: 1, to: startOfEndDate) else {
			return nil
		}

		guard let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: endDate) else {
			return nil
		}

		self.init(start: startDate, end: endDate)
	}
}
