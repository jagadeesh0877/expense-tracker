import Foundation

enum RewriteStyle: String, CaseIterable, Identifiable {
	case formal, simple, funny, emoji
	var id: String { rawValue }

	var title: String {
		switch self {
		case .formal: return "Formal"
		case .simple: return "Simple"
		case .funny: return "Funny"
		case .emoji: return "Emoji"
		}
	}
}

protocol RewriterServiceProtocol {
	func rewrite(_ text: String, style: RewriteStyle) async throws -> String
}

final class RewriterService: RewriterServiceProtocol {
	func rewrite(_ text: String, style: RewriteStyle) async throws -> String {
		switch style {
		case .formal:
			return Self.formalize(text)
		case .simple:
			return Self.simplify(text)
		case .funny:
			return Self.makeFunny(text)
		case .emoji:
			return Self.emojiFy(text)
		}
	}

	private static func formalize(_ text: String) -> String {
		text.replacingOccurrences(of: "can't", with: "cannot")
			.replacingOccurrences(of: "won't", with: "will not")
			.replacingOccurrences(of: "I'm", with: "I am")
	}

	private static func simplify(_ text: String) -> String {
		let sentences = text.split(separator: ".").map(String.init)
		return sentences.map { s in
			let simplified = s.replacingOccurrences(of: "utilize", with: "use")
				.replacingOccurrences(of: "commence", with: "start")
				.replacingOccurrences(of: "terminate", with: "end")
			return simplified
		}.joined(separator: ". ")
	}

	private static func makeFunny(_ text: String) -> String {
		"\(text) 😂 (no cap, just vibes)"
	}

	private static func emojiFy(_ text: String) -> String {
		let map: [String: String] = [
			"happy": "😊", "sad": "😢", "angry": "😡", "love": "❤️", "money": "💸", "school": "🏫", "study": "📚", "deadline": "⏰"
		]
		var result = text
		for (k, v) in map { result = result.replacingOccurrences(of: k, with: v, options: .caseInsensitive) }
		return result + " ✨"
	}
}