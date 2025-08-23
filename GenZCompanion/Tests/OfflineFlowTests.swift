import XCTest
@testable import GenZCompanion

final class OfflineFlowTests: XCTestCase {
	func testSummarizerProducesBullets() async throws {
		let s = SummarizerService()
		let bullets = try await s.summarize("This is important. Result is ready. Conclusion: works.", maxBullets: 3)
		XCTAssertFalse(bullets.isEmpty)
	}

	func testRewriterFormalizes() async throws {
		let r = RewriterService()
		let out = try await r.rewrite("I'm happy we can't go.", style: .formal)
		XCTAssertTrue(out.contains("I am"))
		XCTAssertTrue(out.contains("cannot"))
	}

	func testEntitlementUsageLimit() {
		let gate = EntitlementGating()
		gate.setPro(false)
		var successes = 0
		for _ in 0..<20 { if gate.consumeFreeSummaryIfAvailable() { successes += 1 } }
		XCTAssertEqual(successes, UsageLimits.freeMonthlySummaries)
	}
}