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
}
