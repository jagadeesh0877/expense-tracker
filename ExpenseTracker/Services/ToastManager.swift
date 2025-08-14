import Foundation
import SwiftUI

struct Toast: Identifiable, Equatable {
	enum Style { case info, success, warning, error }
	let id = UUID()
	let style: Style
	let title: String
	let message: String?
	let duration: TimeInterval
	let tapAction: (() -> Void)?
	
	init(style: Style, title: String, message: String? = nil, duration: TimeInterval = 3.0, tapAction: (() -> Void)? = nil) {
		self.style = style
		self.title = title
		self.message = message
		self.duration = duration
		self.tapAction = tapAction
	}
}

final class ToastManager: ObservableObject {
	static let shared = ToastManager()
	@Published var toasts: [Toast] = []
	
	func show(_ toast: Toast) {
		DispatchQueue.main.async {
			self.toasts.append(toast)
			DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration) {
				self.remove(toast)
			}
		}
	}
	
	func remove(_ toast: Toast) {
		toasts.removeAll { $0.id == toast.id }
	}
}