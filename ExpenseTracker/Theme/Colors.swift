import SwiftUI

extension Color {
	static let brandRed = Color(hex: "#e00800")
	static let surface = Color(hex: "#f7f7f7")
	static let textPrimary = Color(UIColor.label)
	static let textSecondary = Color(UIColor.secondaryLabel)
	static let amber = Color(.displayP3, red: 1.0, green: 0.75, blue: 0.2, opacity: 1.0)
}

extension UIColor {
	static let brandRed = UIColor(Color.brandRed)
	static let surface = UIColor(Color.surface)
}