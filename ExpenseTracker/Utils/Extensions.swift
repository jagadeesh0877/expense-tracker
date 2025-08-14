import Foundation
import SwiftUI

extension Color {
	init(hex: String) {
		let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hexString).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hexString.count {
		case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default: (a, r, g, b) = (255, 0, 0, 0)
		}
		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue: Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}

extension Date {
	var startOfDayLocal: Date { Calendar.current.startOfDay(for: self) }
}