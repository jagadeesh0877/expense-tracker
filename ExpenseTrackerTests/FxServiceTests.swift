import XCTest
@testable import ExpenseTracker

final class FxServiceTests: XCTestCase {
	func testAEDBaseConversionDivide() throws {
		let fx = FxService()
		let amountUSD: Decimal = 100
		// Placeholder AED->USD ~ 0.2723, so USD->AED = 100 / 0.2723 ≈ 367.25
		let converted = fx.convertToBase(amount: amountUSD, currencyCode: "USD")!
		XCTAssert(abs((converted as NSDecimalNumber).doubleValue - (100.0 / 0.2723)) < 0.01)
	}
	
	func testApplyPastedJSONValidatesBase() throws {
		let fx = FxService()
		let json = """
		{"base":"AED","asOf":"2025-01-05T00:00:00Z","rates":{"USD":0.27},"lastUpdated":"2025-01-05T05:30:00Z"}
		""".data(using: .utf8)!
		XCTAssertNoThrow(try fx.applyPastedJSON(json))
	}
}