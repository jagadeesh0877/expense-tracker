import SwiftUI

struct BrandButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(.headline)
			.padding(.vertical, 12)
			.padding(.horizontal, 16)
			.background(RoundedRectangle(cornerRadius: 12).fill(Color.brandRed))
			.foregroundColor(.white)
			.scaleEffect(configuration.isPressed ? 0.97 : 1.0)
			.animation(.spring(response: 0.35, dampingFraction: 0.8), value: configuration.isPressed)
	}
}

extension View {
	func motionAwareSpring(enabled: Bool = true) -> Animation {
		if UIAccessibility.isReduceMotionEnabled || !enabled {
			return .easeInOut(duration: 0.2)
		}
		return .spring(response: 0.5, dampingFraction: 0.85)
	}
}