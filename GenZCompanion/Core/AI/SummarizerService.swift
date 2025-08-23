import Foundation
import NaturalLanguage

protocol SummarizerServiceProtocol {
	func summarize(_ text: String, maxBullets: Int) async throws -> [String]
	func detectActionItems(_ text: String) -> [String]
}

final class SummarizerService: SummarizerServiceProtocol {
	func summarize(_ text: String, maxBullets: Int = 5) async throws -> [String] {
		let sentences = Self.splitIntoSentences(text)
		let scored = Self.scoreSentences(sentences)
		return Array(scored.prefix(maxBullets)).map { $0.sentence }
	}

	func detectActionItems(_ text: String) -> [String] {
		let cues = ["todo", "to-do", "action", "remind", "follow up", "call", "email", "buy", "schedule", "meet"]
		return text
			.lowercased()
			.components(separatedBy: .newlines)
			.flatMap { $0.split(separator: ".").map(String.init) }
			.filter { line in cues.contains { cue in line.contains(cue) } }
	}

	// MARK: - Helpers
	private static func splitIntoSentences(_ text: String) -> [String] {
		let tokenizer = NLTokenizer(unit: .sentence)
		tokenizer.string = text
		var ranges: [Range<String.Index>] = []
		tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { range, _ in
			ranges.append(range)
			return true
		}
		return ranges.map { String(text[$0]).trimmingCharacters(in: .whitespacesAndNewlines) }
	}

	private static func scoreSentences(_ sentences: [String]) -> [(sentence: String, score: Double)] {
		let keywords = ["important", "note", "summary", "key", "main", "result", "conclusion", "decision"]
		let scored = sentences.map { s -> (String, Double) in
			let lengthScore = min(Double(s.count) / 120.0, 1.0)
			let keywordScore = keywords.reduce(0.0) { $0 + (s.lowercased().contains($1) ? 0.3 : 0.0) }
			return (s, lengthScore + keywordScore)
		}
		return scored.sorted { $0.1 > $1.1 }
	}
}