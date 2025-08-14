import SwiftUI

struct ToastView: View {
	@EnvironmentObject var manager: ToastManager
	var body: some View {
		VStack {
			Spacer()
			ForEach(manager.toasts) { toast in
				HStack(alignment: .top, spacing: 12) {
					Image(systemName: icon(for: toast.style))
						.foregroundColor(.white)
					VStack(alignment: .leading, spacing: 4) {
						Text(toast.title).bold().foregroundColor(.white)
						if let message = toast.message { Text(message).foregroundColor(.white.opacity(0.9)).font(.subheadline) }
					}
					Spacer(minLength: 0)
				}
				.padding()
				.background(RoundedRectangle(cornerRadius: 14).fill(Color.black.opacity(0.85)))
				.padding(.horizontal)
				.onTapGesture {
					toast.tapAction?()
					manager.remove(toast)
				}
			}
		}
		.animation(.spring(), value: manager.toasts)
	}
	
	private func icon(for style: Toast.Style) -> String {
		switch style {
		case .info: return "info.circle.fill"
		case .success: return "checkmark.circle.fill"
		case .warning: return "exclamationmark.triangle.fill"
		case .error: return "xmark.octagon.fill"
		}
	}
}