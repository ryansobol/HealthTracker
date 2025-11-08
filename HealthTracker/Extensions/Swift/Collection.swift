extension Collection where Element == Double {
	var average: Double? {
		guard !self.isEmpty else {
			return nil
		}

		return self.reduce(0, +) / Double(self.count)
	}
}
