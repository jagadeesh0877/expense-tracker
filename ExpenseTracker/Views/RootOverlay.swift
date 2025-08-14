import SwiftUI

struct RootOverlay<Content: View>: View {
	@EnvironmentObject var toast: ToastManager
	let content: Content
	init(@ViewBuilder content: () -> Content) { self.content = content() }
	var body: some View {
		ZStack(alignment: .bottom) {
			content
			ToastView().environmentObject(toast).padding(.bottom, 16)
		}
	}
}