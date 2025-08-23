import Foundation

final class LocalQAService {
	private let summarizer: SummarizerServiceProtocol

	init(summarizer: SummarizerServiceProtocol) {
		self.summarizer = summarizer
	}

	func answer(question: String, context: String) async throws -> String {
		let lines = context.components(separatedBy: .newlines)
		let hits = lines.filter { $0.lowercased().contains(whereAnyOf: question.lowercased().words()) }
		let condensed = hits.joined(separator: " ")
		let bullets = try await summarizer.summarize(condensed, maxBullets: 3)
		return bullets.joined(separator: "\n• ")
	}
}

private extension StringProtocol {
	func words() -> [String] {
		lowercased().split { !$0.isLetter && !$0.isNumber }.map(String.init)
	}

	func contains(whereAnyOf tokens: [String]) -> Bool {
		for t in tokens where !t.isEmpty {
			if self.lowercased().contains(t) { return true }
		}
		return false
	}
}