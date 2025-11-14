import SwiftUI

extension View {
	@ViewBuilder
	func alert(for alertable: Binding<(some Alertable)?>) -> some View {
		if let wrappedValue = alertable.wrappedValue {
			self.alert(
				wrappedValue.title,
				isPresented: Binding(optionalValue: alertable),
				actions: { wrappedValue.actions },
				message: { wrappedValue.message },
			)
		}
		else {
			self
		}
	}

	/// Sets a boolean binding to true once when a condition becomes true.
	///
	/// This modifier observes the condition and sets the binding to true the first time
	/// the condition becomes true. Once the binding is set to true, it will not be modified
	/// again, even if the condition changes.
	///
	/// - Parameters:
	///   - binding: A boolean binding to set to true
	///   - condition: A boolean condition to observe
	///
	/// - Returns: A view that sets the binding when the condition is met
	func setTrue(_ binding: Binding<Bool>, when condition: Bool) -> some View {
		return self.modifier(SetTrueViewModifier(condition: condition, binding: binding))
	}
}
