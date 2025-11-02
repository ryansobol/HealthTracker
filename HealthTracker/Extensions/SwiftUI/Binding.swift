import SwiftUI

extension Binding where Value == Bool {
	init(optionalValue: Binding<(some Any)?>) {
		self.init(
			get: { optionalValue.wrappedValue != nil },
			set: { if !$0 { optionalValue.wrappedValue = nil }},
		)
	}
}
