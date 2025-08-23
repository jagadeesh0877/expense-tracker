import SwiftUI
import UniformTypeIdentifiers

struct PDFSummarizerView: View {
	@State private var pickedURL: URL?
	@State private var bullets: [String] = []
	@State private var question: String = ""
	@State private var answer: String = ""
	@State private var isImporterPresented = false
	@State private var isBusy = false

	private let service = PDFService()

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading, spacing: 16) {
					Button {
						isImporterPresented = true
					} label: {
						Label("Import PDF", systemImage: "doc.badge.plus")
					}

					if let url = pickedURL {
						Text("Selected: \(url.lastPathComponent)")
					}

					if !bullets.isEmpty {
						SectionHeader(title: "Summary")
						ForEach(bullets, id: \.self) { b in Text("• \(b)") }
					}

					SectionHeader(title: "Ask a Question")
					TextField("e.g., What are the key findings?", text: $question)
						.textFieldStyle(.roundedBorder)
					Button("Ask") { Task { await ask() } }
					if !answer.isEmpty { Text(answer).font(.callout) }
				}
				.padding()
			}
			.navigationTitle("PDF Summarizer")
		}
		.fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.pdf]) { result in
			switch result {
			case .success(let url):
				pickedURL = url
				Task { await summarize() }
			case .failure(let error):
				print("Picker error: \(error)")
			}
		}
	}

	private func summarize() async {
		guard let url = pickedURL else { return }
		isBusy = true
		defer { isBusy = false }
		do { bullets = try await service.summarizePDF(at: url) } catch { bullets = ["Failed: \(error.localizedDescription)"] }
	}

	private func ask() async {
		guard let url = pickedURL, !question.isEmpty else { return }
		isBusy = true
		defer { isBusy = false }
		do { answer = try await service.answerQuestion(question, from: url) } catch { answer = "Failed: \(error.localizedDescription)" }
	}
}