import Foundation
import Combine

final class FxService: ObservableObject {
	static let shared = FxService()
	
	enum RefreshReason: Equatable { case appLaunchOrForeground, backgroundTask, manual }
	
	@Published private(set) var currentRates: FxRates
	private let session: URLSession
	private let fileURL: URL
	private let jsonEncoder = JSONEncoder()
	private let jsonDecoder = JSONDecoder()
	private var cancellables: Set<AnyCancellable> = []
	
	private let calendar = Calendar.current
	private var lastAttempt: Date? {
		get { UserDefaults.standard.object(forKey: "FxService.lastAttempt") as? Date }
		set { UserDefaults.standard.set(newValue, forKey: "FxService.lastAttempt") }
	}
	
	init(session: URLSession = .shared) {
		self.session = session
		self.jsonEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		self.jsonDecoder.dateDecodingStrategy = .iso8601
		self.jsonEncoder.dateEncodingStrategy = .iso8601
		self.fileURL = FxService.fxRatesFileURL()
		self.currentRates = FxService.loadCachedRates(from: self.fileURL) ?? FxRates.placeholder
	}
	
	func refreshIfNeeded(reason: RefreshReason) {
		let today = calendar.startOfDay(for: Date())
		let lastAttemptDay = lastAttempt.map { calendar.startOfDay(for: $0) }
		guard lastAttemptDay == nil || lastAttemptDay! < today else { return }
		lastAttempt = Date()
		Task { await self.refreshRates(reason: reason) }
	}
	
	@discardableResult
	func refreshRates(reason: RefreshReason) async -> Bool {
		do {
			let fetched = try await fetchAEDBaseFromECB()
			DispatchQueue.main.async {
				self.currentRates = fetched
				self.saveCachedRates()
			}
			return true
		} catch {
			DispatchQueue.main.async {
				ToastManager.shared.show(.init(style: .warning, title: "Using last known FX rates", message: "Latest refresh failed"))
			}
			return false
		}
	}
	
	func convertToBase(amount: Decimal, currencyCode: String) -> Decimal? {
		if currencyCode.uppercased() == FxRates.baseCurrencyCode { return amount }
		guard let rate = currentRates.rates[currencyCode.uppercased()], rate > 0 else { return nil }
		let nsAmount = amount as NSDecimalNumber
		let converted = nsAmount.dividing(by: NSDecimalNumber(value: rate))
		return converted as Decimal
	}
	
	func updateRate(code: String, aedToCurrency: Double) {
		var updated = currentRates.rates
		updated[code.uppercased()] = aedToCurrency
		let now = Date()
		let newRates = FxRates(base: FxRates.baseCurrencyCode, asOf: currentRates.asOf, rates: updated, lastUpdated: now)
		currentRates = newRates
		saveCachedRates()
	}
	
	func applyPastedJSON(_ data: Data) throws {
		let decoded = try jsonDecoder.decode(FxRates.self, from: data)
		guard decoded.base.uppercased() == FxRates.baseCurrencyCode else {
			throw NSError(domain: "FxService", code: 1, userInfo: [NSLocalizedDescriptionKey: "JSON must be AED-base"])
		}
		DispatchQueue.main.async {
			self.currentRates = decoded
			self.saveCachedRates()
		}
	}
	
	private func fetchAEDBaseFromECB() async throws -> FxRates {
		let url = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")!
		let (data, _) = try await session.data(from: url)
		let parsed = try parseECBXML(data: data)
		guard let eurToAED = parsed["AED"], eurToAED > 0 else {
			throw NSError(domain: "FxService", code: 2, userInfo: [NSLocalizedDescriptionKey: "EUR->AED rate not found in ECB feed"])
		}
		var aedBase: [String: Double] = [:]
		for (code, eurToX) in parsed {
			let aedToX = (1.0 / eurToAED) * eurToX
			aedBase[code] = aedToX
		}
		aedBase[FxRates.baseCurrencyCode] = 1.0
		let now = Date()
		return FxRates(base: FxRates.baseCurrencyCode, asOf: now, rates: aedBase, lastUpdated: now)
	}
	
	private func parseECBXML(data: Data) throws -> [String: Double] {
		guard let xml = String(data: data, encoding: .utf8) else {
			throw NSError(domain: "FxService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid ECB encoding"])
		}
		var result: [String: Double] = [:]
		let pattern = "currency=\"([A-Z]{3})\"\s+rate=\"([0-9.]+)\""
		let regex = try NSRegularExpression(pattern: pattern)
		let nsrange = NSRange(xml.startIndex..<xml.endIndex, in: xml)
		regex.enumerateMatches(in: xml, options: [], range: nsrange) { match, _, _ in
			guard let match = match,
				let codeRange = Range(match.range(at: 1), in: xml),
				let rateRange = Range(match.range(at: 2), in: xml) else { return }
			let code = String(xml[codeRange])
			let rateStr = String(xml[rateRange])
			if let rate = Double(rateStr) {
				result[code] = rate
			}
		}
		if result["AED"] == nil {
			if let aedFromHost = try? fetchEURBaseFromExchangeRateHost(), let eurToAED = aedFromHost["AED"] {
				result["AED"] = eurToAED
			}
		}
		return result
	}
	
	private func fetchEURBaseFromExchangeRateHost() throws -> [String: Double]? {
		let sema = DispatchSemaphore(value: 0)
		var output: [String: Double]? = nil
		var doneError: Error? = nil
		let url = URL(string: "https://api.exchangerate.host/latest?base=EUR")!
		let task = session.dataTask(with: url) { data, _, error in
			defer { sema.signal() }
			if let error = error { doneError = error; return }
			guard let data = data else { return }
			struct HostResponse: Decodable { let rates: [String: Double] }
			if let resp = try? JSONDecoder().decode(HostResponse.self, from: data) {
				output = resp.rates
			}
		}
		task.resume()
		_ = sema.wait(timeout: .now() + 10)
		if doneError != nil { return nil }
		return output
	}
	
	private static func fxRatesFileURL() -> URL {
		let fm = FileManager.default
		let dir = (try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) ?? fm.temporaryDirectory
		let appDir = dir.appendingPathComponent("ExpenseTracker", isDirectory: true)
		try? fm.createDirectory(at: appDir, withIntermediateDirectories: true)
		return appDir.appendingPathComponent("fxRates.json")
	}
	
	private static func loadCachedRates(from url: URL) -> FxRates? {
		guard let data = try? Data(contentsOf: url) else { return nil }
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return try? decoder.decode(FxRates.self, from: data)
	}
	
	private func saveCachedRates() {
		guard let data = try? jsonEncoder.encode(currentRates) else { return }
		try? data.write(to: fileURL, options: [.atomic])
	}
}