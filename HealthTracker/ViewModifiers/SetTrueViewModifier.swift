import SwiftUI

struct SetTrueViewModifier: ViewModifier {
	let condition: Bool
	let binding: Binding<Bool>

	func body(content: Content) -> some View {
		content
			.onChange(of: self.condition, initial: true) { _, newValue in
				guard !self.binding.wrappedValue else {
					return
				}

				guard newValue else {
					return
				}

				self.binding.wrappedValue = true
			}
	}
}
