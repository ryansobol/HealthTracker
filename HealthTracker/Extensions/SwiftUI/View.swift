import SwiftUI

extension View {
	@ViewBuilder
	func alert(
		throwable error: Binding<(some Throwable)?>,
	) -> some View {
		if let wrappedValue = error.wrappedValue {
			self.alert(
				wrappedValue.errorDescription,
				isPresented: Binding(optionalValue: error),
				actions: { wrappedValue.actions },
				message: { wrappedValue.message },
			)
		}
		else {
			self
		}
	}
}
