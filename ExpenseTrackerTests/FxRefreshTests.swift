import XCTest
@testable import ExpenseTracker

final class FxRefreshTests: XCTestCase {
	func testRefreshIfNeededOnlyAfterDayRollover() async throws {
		let fx = FxService()
		UserDefaults.standard.set(Date(), forKey: "FxService.lastAttempt")
		let before = fx.currentRates
		fx.refreshIfNeeded(reason: .appLaunchOrForeground)
		XCTAssertEqual(before.lastUpdated.startOfDayLocal, fx.currentRates.lastUpdated.startOfDayLocal)
	}
}