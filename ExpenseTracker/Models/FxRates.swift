import Foundation

struct FxRates: Codable, Equatable {
	let base: String
	let asOf: Date
	let rates: [String: Double]
	let lastUpdated: Date
	
	static let baseCurrencyCode = "AED"
	
	static var placeholder: FxRates {
		let iso = ISO8601DateFormatter()
		let asOf = iso.date(from: "2025-01-05T00:00:00Z") ?? Date()
		let updated = iso.date(from: "2025-01-05T05:30:00Z") ?? Date()
		return FxRates(
			base: FxRates.baseCurrencyCode,
			asOf: asOf,
			rates: [
				"USD": 0.2723, "EUR": 0.2490, "INR": 22.50, "GBP": 0.2150,
				"SAR": 1.0200, "KWD": 0.0830, "QAR": 0.9930, "OMR": 0.1040, "BHD": 0.1030,
				"PKR": 75.0, "LKR": 82.0, "EGP": 13.0
			],
			lastUpdated: updated
		)
	}
}