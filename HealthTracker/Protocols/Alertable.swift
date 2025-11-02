import SwiftUI

protocol Alertable {
	var title: String { get }

	associatedtype ActionsBody: View
	@ViewBuilder var actions: Self.ActionsBody { get }

	associatedtype MessageBody: View
	@ViewBuilder var message: Self.MessageBody { get }
}
