import Foundation
import Combine

final class Settings: ObservableObject {
	static let shared = Settings()
	
	@Published var baseCurrencyCode: String { didSet { save() } }
	@Published var weekStartsOn: String { didSet { save() } } // "sun" or "mon"
	@Published var privacyMode: Bool { didSet { save() } }
	@Published var density: String { didSet { save() } } // "compact" or "cozy"
	@Published var fontScale: Double { didSet { save() } } // 0.9 - 1.3
	
	private let defaults = UserDefaults.standard
	private let key = "Settings.v1"
	
	private init() {
		if let data = defaults.data(forKey: key), let decoded = try? JSONDecoder().decode(SelfDTO.self, from: data) {
			self.baseCurrencyCode = decoded.baseCurrencyCode
			self.weekStartsOn = decoded.weekStartsOn
			self.privacyMode = decoded.privacyMode
			self.density = decoded.density
			self.fontScale = decoded.fontScale
		} else {
			self.baseCurrencyCode = FxRates.baseCurrencyCode
			self.weekStartsOn = "sun"
			self.privacyMode = false
			self.density = "cozy"
			self.fontScale = 1.0
			save()
		}
	}
	
	private func save() {
		let dto = SelfDTO(baseCurrencyCode: baseCurrencyCode, weekStartsOn: weekStartsOn, privacyMode: privacyMode, density: density, fontScale: fontScale)
		if let data = try? JSONEncoder().encode(dto) { defaults.set(data, forKey: key) }
	}
	
	private struct SelfDTO: Codable {
		let baseCurrencyCode: String
		let weekStartsOn: String
		let privacyMode: Bool
		let density: String
		let fontScale: Double
	}
}