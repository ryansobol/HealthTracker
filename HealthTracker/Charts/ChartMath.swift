import Algorithms

enum ChartMath {
	static func averageWeekdayCount(for metrics: [HealthMetric]) -> [WeekdayChartData] {
		let sortedByWeekday = metrics.sorted { $0.date.weekdayInt < $1.date.weekdayInt }
		let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }

		var result = [WeekdayChartData]()

		for array in weekdayArray {
			guard let date = array.first?.date else { continue }

			let value = array.reduce(0) { $0 + $1.value } / Double(array.count)

			result.append(.init(date: date, value: value))
		}

		return result
	}
}
