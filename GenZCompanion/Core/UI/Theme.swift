import SwiftUI

enum AppTheme {
	static let gradient = LinearGradient(
		colors: [Color.purple, Color.blue, Color.green],
		startPoint: .topLeading,
		endPoint: .bottomTrailing
	)
}

extension Color {
	static let accent = Color(hex: 0x7A5CFF)
}

extension Color {
	init(hex: UInt, alpha: Double = 1.0) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xff) / 255.0,
			green: Double((hex >> 8) & 0xff) / 255.0,
			blue: Double((hex) & 0xff) / 255.0,
			opacity: alpha
		)
	}
}