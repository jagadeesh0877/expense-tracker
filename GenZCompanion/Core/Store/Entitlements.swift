import Foundation

enum Entitlement: String, CaseIterable {
	case pro
}

struct UsageLimits {
	static let freeMonthlySummaries = 10
}

final class EntitlementGating: ObservableObject {
	@Published var isPro: Bool = false
	@Published var remainingFreeSummaries: Int = UsageLimits.freeMonthlySummaries

	private let defaults = UserDefaults.standard
	private let monthKey = "usage_month_key"
	private let usedKey = "usage_used_key"

	init() {
		resetIfNeeded()
		remainingFreeSummaries = max(0, UsageLimits.freeMonthlySummaries - defaults.integer(forKey: usedKey))
	}

	func consumeFreeSummaryIfAvailable() -> Bool {
		resetIfNeeded()
		guard !isPro else { return true }
		let used = defaults.integer(forKey: usedKey)
		if used < UsageLimits.freeMonthlySummaries {
			defaults.set(used + 1, forKey: usedKey)
			remainingFreeSummaries = max(0, UsageLimits.freeMonthlySummaries - (used + 1))
			return true
		}
		return false
	}

	func setPro(_ value: Bool) {
		isPro = value
	}

	private func resetIfNeeded() {
		let currentMonth = Self.currentMonthToken()
		let stored = defaults.string(forKey: monthKey)
		if stored != currentMonth {
			defaults.set(currentMonth, forKey: monthKey)
			defaults.set(0, forKey: usedKey)
		}
	}

	private static func currentMonthToken() -> String {
		let comps = Calendar.current.dateComponents([.year, .month], from: Date())
		return "\(comps.year ?? 0)-\(comps.month ?? 0)"
	}
}