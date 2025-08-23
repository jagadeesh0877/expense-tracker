import SwiftUI

struct TextRewriterView: View {
	@State private var input: String = ""
	@State private var output: String = ""
	@State private var style: RewriteStyle = .formal
	@State private var isBusy = false

	private let rewriter: RewriterServiceProtocol = RewriterService()

	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 16) {
				Picker("Style", selection: $style) {
					ForEach(RewriteStyle.allCases) { s in Text(s.title).tag(s) }
				}
				.pickerStyle(.segmented)
				TextEditor(text: $input)
					.frame(minHeight: 140)
					.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
				Button("Rewrite") { Task { await doRewrite() } }
				Text(output).textSelection(.enabled)
				Spacer()
			}
			.padding()
			.navigationTitle("Text Rewriter")
		}
	}

	private func doRewrite() async {
		guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
		isBusy = true
		defer { isBusy = false }
		do { output = try await rewriter.rewrite(input, style: style) } catch { output = "Failed: \(error.localizedDescription)" }
	}
}