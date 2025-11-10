import SwiftUI

protocol Alertable {
	var title: String { get }

	associatedtype Actions: View
	@ViewBuilder var actions: Actions { get }

	associatedtype Message: View
	@ViewBuilder var message: Message { get }
}
