import Foundation
import PDFKit

final class PDFService {
	private let summarizer: SummarizerServiceProtocol

	init(summarizer: SummarizerServiceProtocol = SummarizerService()) {
		self.summarizer = summarizer
	}

	func extractText(from url: URL) -> String {
		guard let doc = PDFDocument(url: url) else { return "" }
		var text = ""
		for i in 0..<(doc.pageCount) {
			if let page = doc.page(at: i), let pageText = page.string { text += pageText + "\n" }
		}
		return text
	}

	func summarizePDF(at url: URL, maxBullets: Int = 5) async throws -> [String] {
		let text = extractText(from: url)
		return try await summarizer.summarize(text, maxBullets: maxBullets)
	}

	func answerQuestion(_ question: String, from url: URL) async throws -> String {
		let text = extractText(from: url)
		let qa = LocalQAService(summarizer: summarizer)
		return try await qa.answer(question: question, context: text)
	}
}